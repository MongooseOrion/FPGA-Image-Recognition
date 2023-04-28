# �ܽ�Լ���ο���ģ������˵��

�ڱ�ҳ������������Ŀ�в��ֹܽŵ�Լ���Լ�ģ��������˵��������Ĺܽ�Լ������������� `../FPGA/` �ļ����µ�� `.fdc` �ļ��鿴��

## DDR3

MES50HP �������� 4Gbit��512MB���� DDR3 оƬ������ 8Gbit����DDR �����߿��Ϊ 32bit��DDR3 �Ĵ���ֱ�����ӵ� FPGA �� BANK B3��

�� PDS �У�DDR ģ����Ϊ IP ���ṩ�����ݽӿڰ��� AXI4 lite ���ߺ� APB ���ߡ����� wujian100 ������Ϊ AHB lite Э�飬�����Ҫ AHB Lite ת AXI4 Lite ת���š�������������� `../RTL/ahb_to_axi_bridge.v`��

�� IP �˵� AXI4 Lite �ӿڲ��ֹ����� `x_main_dummy_top3` ��λ�ã�APB �ӿڲ��ֹ����� `x_apb1_dummy_top8` ��λ�á�

��ע�⣬�ڴ˴��Ķ˿����ư��� `IP Catelog` ��������������Ϊ׼�������뿪���ֲ��е�������ͬ��

| �˿��� | ���� | Ӳ���ܽű�� |
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

## MCU ϵͳԼ��

| �˿��� | �ܽű�� | Ӳ��λ�� | �ܽŹ��� |
|:----- | :----: | :-----: |:---- |
| gpioA[31] | | | |
| gpioA[17] | R9 | | UART_TX |
| gpioA[16] | R8 | | UART_RX |
| gpioA[13] | F15 | | EEPROM(IIC)_SCL |
| gpioA[12] | G8 | | EEPROM(IIC)_SDA |
| ======= | ====== | ======= | ========= |
| mcu_wakeup | H20 | KEY7 | MCU ���� |
| pmu_padon | F7 | LED7 | MCU ��Դָʾ |
| pmu_padrst | F8 | LED8 | MCU ��λָʾ |
| ======= | ====== | ======= | ========= |
| qspi0_dq[3] | T14 | QSPI_7 | QSPI ����λ |
| qspi0_dq[2] | R13 | QSPI_3 | QSPI ����λ |
| qspi0_dq[1] | AA20 | QSPI_2 | QSPI ����λ |
| qspi0_dq[0] | AB20 | QSPI_5 | QSPI ����λ |
| qspi0_cs | AA3 | QSPI_1 | QSPI Ƭѡ |
| qspi0_sck | Y20 | QSPI_6 | ��������ʱ�� |
| clkin1 | P20 | NULL | clock |
| globalrst | H17 | KEY8 | reset |