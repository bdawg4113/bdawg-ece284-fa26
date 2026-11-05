import torch
import torch.nn as nn
import torch.nn.functional as F
from models.quant_layer import weight_quantize_fn, act_quantization


class QuantConv2d(nn.Conv2d):
    """QuantConv2d with a configurable bit width (default 2) instead of the hard-coded 4."""
    def __init__(self, in_channels, out_channels, kernel_size, stride=1, padding=0, dilation=1, groups=1,
                 bias=False, bit=2, act_alpha_init=8.0):
        super(QuantConv2d, self).__init__(in_channels, out_channels, kernel_size, stride, padding, dilation,
                                          groups, bias)
        self.layer_type = 'QuantConv2d'
        self.bit = bit
        self.weight_quant = weight_quantize_fn(w_bit=self.bit)
        self.act_alq = act_quantization(self.bit)
        self.act_alpha = torch.nn.Parameter(torch.tensor(float(act_alpha_init)))
        self.weight_q = torch.nn.Parameter(torch.zeros([out_channels, in_channels, kernel_size, kernel_size]))

    def forward(self, x):
        weight_q = self.weight_quant(self.weight)
        self.weight_q = torch.nn.Parameter(weight_q)  # keep the quantized weight for inspection
        x = self.act_alq(x, self.act_alpha)
        return F.conv2d(x, weight_q, self.bias, self.stride, self.padding, self.dilation, self.groups)

    def show_params(self):
        wgt_alpha = round(self.weight_quant.wgt_alpha.data.item(), 3)
        act_alpha = round(self.act_alpha.data.item(), 3)
        print('clipping threshold weight alpha: {:2f}, activation alpha: {:2f}'.format(wgt_alpha, act_alpha))
