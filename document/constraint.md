# 管脚约束参考和模块连接说明

在本页，将给出该项目中部分管脚的约束以及模块间的连线说明。具体的管脚约束配置你可以在 `../FPGA/` 文件夹下点击 `.fdc` 文件查看。

## DDR3

MES50HP 配有两个 4Gbit（512MB）的 DDR3 芯片（共计 8Gbit），DDR 的总线宽度为 32bit。DDR3 的储存直接连接到 FPGA 的 BANK B3。

在 PDS 中，DDR 模块作为 IP 核提供，数据接口包括 AXI4 lite 总线和 APB 总线。

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

## FPGA I/O 接口约束

| 资源编号 | 占用的信号名称 | 信号作用 |
| :---- | :-----: | :-----: |
| LED_1 | hdmi_int_led | HDMI 初始化成功指示 |
| LED_2 | ddr_init_done | DDR 初始化成功指示 |
| LED_3 | cmos_init_done[0] | CMOS_1 初始化成功指示 |
| LED_4 | cmos_init_done[1] | CMOS_2 初始化成功指示 |
| LED_5 | heart_beat_led | HDMI 路径工作指示 |
| LED_6 | eth_init | 以太网 UDP 路径工作指示|
| SW_1 | globalrst | 全局复位 |
| SW_2| / | CMOS 切换 |
