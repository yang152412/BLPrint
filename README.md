# BLPrint
蓝牙打印。兼容 佳博 sdk。

### 前言

1、该开始做打印，使用了 `Haley-Wong` 大神的 [demo](https://github.com/Haley-Wong/HLBluetoothDemo) 。在 ios7下 能正常打印，但是到了 ios8、ios9 上之后，要么是 后面部分乱码，要不就是打印机没反应。被折腾了很久，最后只能用佳博他们的官方 sdk。

2、佳博 SDK 把 扫描和连接方法 封装到 CBController 中，如果在扫描界面使用还好，但是我们需要做启动扫描，这个 controller 也必须加载到处理就比较蛋疼。然后这个 controller 如果不加载出来，还不会给回调，异常坑爹。

3、由于产品需求，还需要 兼容其他品牌打印机，而佳博 SDK 封装的扫描方法 结果回调 ，直接把 蓝牙对象 CBPeripheral 封装成了 MyPeripheral 。而这个对象 没有给初始化方法，如果自己来生成这个对象，试了下是打印不出结果的，会包 `Invalid data`。 


郁闷了几天，突然想到一个取巧办法。  CoreBluetooth 的回调就那么几个，我自己扫描，得到的回调，全部再转发给CBController，来 模拟让他 收到 扫描的结果。经过测试之后，发现这个方法可行。这样一来 如果要兼容其他品牌，就可以自己扫描，判断品牌之后，用对应的 sdk 连接就可以了。


### 实现

1、实现比较简单， PrinterUtil 封装 扫描 打印机，打印方法

2、PrinterFormatText 封装了 排版时，拼接字符串的方法。

3、PrinterScanProtocol 定义了扫描的协议，用于每个 sdk 执行自己的扫描方法（虽然我们自己扫描了，但是他们的方法还是要执行以下，以防 他们做了什么处理），和收到回调

4、BLGprinterSDKModel 则是封装 GPrinter 的类，实现了 PrinterScanProtocol 协议。如果要再添加其他 sdk，则再新增对应的 model。
