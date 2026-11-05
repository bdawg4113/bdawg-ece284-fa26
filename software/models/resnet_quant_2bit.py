"""2-bit ResNet-20 for CIFAR-10. All convs (including the first) are 2-bit QuantConv2d."""
import math
import torch
import torch.nn as nn
from models.quant_layer_2bit import QuantConv2d

BIT = 2


def Quantconv3x3(in_planes, out_planes, stride=1):
    return QuantConv2d(in_planes, out_planes, kernel_size=3, stride=stride, padding=1, bias=False, bit=BIT)


class BasicBlock(nn.Module):
    expansion = 1

    def __init__(self, inplanes, planes, stride=1, downsample=None):
        super(BasicBlock, self).__init__()
        self.conv1 = Quantconv3x3(inplanes, planes, stride)
        self.bn1 = nn.BatchNorm2d(planes)
        self.relu = nn.ReLU(inplace=True)
        self.conv2 = Quantconv3x3(planes, planes)
        self.bn2 = nn.BatchNorm2d(planes)
        self.downsample = downsample
        self.stride = stride

    def forward(self, x):
        residual = x
        out = self.relu(self.bn1(self.conv1(x)))
        out = self.bn2(self.conv2(out))
        if self.downsample is not None:
            residual = self.downsample(x)
        out += residual
        return self.relu(out)


class ResNet_Cifar(nn.Module):

    def __init__(self, block, layers, num_classes=10):
        super(ResNet_Cifar, self).__init__()
        self.inplanes = 16
        # first conv is quantized too; its input is the normalized image (~[-2, 2.1]),
        # so act_alpha starts at 2 rather than 8 (otherwise nearly every pixel rounds to 0)
        self.conv1 = QuantConv2d(3, 16, kernel_size=3, stride=1, padding=1, bias=False, bit=BIT,
                                 act_alpha_init=2.0)
        self.bn1 = nn.BatchNorm2d(16)
        self.relu = nn.ReLU(inplace=True)
        self.layer1 = self._make_layer(block, 16, layers[0])
        self.layer2 = self._make_layer(block, 32, layers[1], stride=2)
        self.layer3 = self._make_layer(block, 64, layers[2], stride=2)
        self.avgpool = nn.AvgPool2d(8, stride=1)
        self.fc = nn.Linear(64 * block.expansion, num_classes)

        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                n = m.kernel_size[0] * m.kernel_size[1] * m.out_channels
                m.weight.data.normal_(0, math.sqrt(2. / n))
            elif isinstance(m, nn.BatchNorm2d):
                m.weight.data.fill_(1)
                m.bias.data.zero_()

    def _make_layer(self, block, planes, blocks, stride=1):
        downsample = None
        if stride != 1 or self.inplanes != planes * block.expansion:
            downsample = nn.Sequential(
                QuantConv2d(self.inplanes, planes * block.expansion, kernel_size=1, stride=stride, bias=False,
                            bit=BIT),
                nn.BatchNorm2d(planes * block.expansion)
            )
        layers = [block(self.inplanes, planes, stride, downsample)]
        self.inplanes = planes * block.expansion
        for _ in range(1, blocks):
            layers.append(block(self.inplanes, planes))
        return nn.Sequential(*layers)

    def forward(self, x):
        x = self.relu(self.bn1(self.conv1(x)))
        x = self.layer3(self.layer2(self.layer1(x)))
        x = self.avgpool(x)
        x = x.view(x.size(0), -1)
        return self.fc(x)

    def show_params(self):
        for m in self.modules():
            if isinstance(m, QuantConv2d):
                m.show_params()


def resnet20_quant_2bit(**kwargs):
    return ResNet_Cifar(BasicBlock, [3, 3, 3], **kwargs)
