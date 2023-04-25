# 管脚约束参考和模块连接说明

在本页，将给出该项目中部分管脚的约束以及模块间的连线说明。具体的管脚约束配置你可以在 `../FPGA/` 文件夹下点击 `.fdc` 文件查看。

## DDR3

MES50HP 配有两个 4Gbit（512MB）的 DDR3 芯片（共计 8Gbit），DDR 的总线宽度为 32bit。DDR3 的储存直接连接到 FPGA 的 BANK B3。

在 PDS 中，DDR 模块作为 IP 核提供，数据接口包括 AXI4 lite 总线和 APB 总线。由于 wujian100 的总线为 AHB lite 协议，因此需要 AHB Lite 转 AXI4 Lite 转接桥。具体内容请参阅 `../RTL/ahb_to_axi_bridge.v`。

该 IP 核的 AXI4 Lite 接口部分挂载在 `x_main_dummy_top3` 的位置，APB 接口部分挂载在 `x_apb1_dummy_top8` 的位置。

请注意，在此处的端口名称按照 `IP Catelog` 中所给出的命名为准，可能与开发手册中的有所不同。

| 端口名 | 组编号 | 硬件管脚编号 |
| ----- | :----: | :-----: |
| RESET | NULL | C1 |
| CKE | G8 | Y3 |
| CK | G8 | T6 |
| CK_N | G8 | T5 |
| CS | G0 | G6 |
| RAS | G0 | J7 |
| CAS | G0 | H8 |
| WE | G0 | H6 |
| ODT | G0 | G7 |
| BA0 | G0 | F5 |
| BA1 | G8 | W4 |
| BA2 | G6 | N7 |
| === | === | === |
| A0 | G6 | N6 |
| A1 | G6 | R4 |
| A2 | G6 | P6 |
| A3 | G1 | F3 |
| A4 | G8 | V5 |
| A5 | G1 | E4 |
| A6 | G8 | V3 |
| A7 | G1 | D2 |
| A8 | G6 | U4 |
| === | === | === |
| A9 | G8 | P5 |
| A10 | G8 | P8 |
| A11 | G6 | T4 |
| A12 | G6 | P7 |
| A13 | G8 | P4 |
| A14 | G6 | T3 |
| === | === | === |
| DQ[0-7] | B3 | G5 |
| DQ[8-15] | B3 | G4 |
| DQ[16-23] | B3 | G3 |
| DQ[24-31] | B3 | G2 |

## HDMI

 