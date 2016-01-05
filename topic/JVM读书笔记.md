# JVM读书笔记

## 虚拟机类加载机制

### 类加载时机

生命周期：加载，验证，准备，解析，初始化，使用，卸载

#### 开始加载的时机

1. 遇到new，getstatic, putstatic, 或 invokestatic这4条指令时，有虚拟机具体实现把握(注意：被final修饰，已在编译期把结果放入到常量池的静态字段除外)。
2. 对类进行反射调用。
3. 初始化一个类时，发现其父类还没有进行过初始化，则先触发其父类的初始化。
4. 启动虚拟机时，main()方法所在的类。
5. JDK 1.7动态语言支持时，如果一个java.lang.invoke.MethodHandle实例最后的解析结果REF_getStatic, REF_putStatic, REF_invokeStatic的方法句柄，并且这个方法句柄所对应的类并没有进行过初始化，则需要先触发其初始化。

#### 加载

读取zip文件，生成Class对象引用

#### 准备

1. 类成员变量执行初始赋值，仅包括类(static修饰)成员变量，不包括实例变量，实例变量在对象实例化时随着对象一起分配到Java堆中。
   
2. 这儿的初始赋值，非final修饰为数据类型的零值，如
   
   ```public static int value = 123;```
   
   其初始值为0，而不是123，`reference`类型初始零值为`null`
   
3. 对于类成员存在ConstantValue属性，则准备阶段变量value初始化为ConstantValue属性所指定的值，如下则为`123`
   
   ```public static final int value = 123 ```

#### 初始化

1. 真正开始执行类中定义的JAVA程序代码(或者说是字节码)。
2. 初始化阶段是执行类构造器`<cinit>()`方法的过程。
3. `<cinit>()`方法由编译器自动收集类中所有类变量的复制操作和`static{}`语句块合并生成的，收集的顺序由语句在源文件中出现的顺序决定。
4. `<cinit>()`方法不需要显示的调用父类构造器，虚拟机保证在子类的`<cinit>()`调用之前，父类的`<cinit>()`方法已经执行完毕。所以在虚拟机中第一个被执行的`<cinit>()`方法的类肯定是Object。
5. `<cinit>()`方法并不是必须的，需要就生成，不需要就算了。
6. 接口也有`<cinit>()`，但是接口可以不用先调用父接口的`<cinit>()`，除非子接口显示调用了父接口中定义的常量。
7. 虚拟机保证`<cinit>()`方法调用线程安全。

### 类加载器

对于任意一个类，需要由加载它的类加载器和这个类本身一同确立其在JVM中的唯一性，每一个类加载器在JVM中都有一个独立的类命名空间。

#### 系统提供的类加载器

1. 启动类加载器(Bootstrap ClassLoader)：加载`$JAVA_HOME/lib/`，或者被`-Xbootclasspath`指定的路径中，并且文件名被虚拟机识别的类库加载到虚拟机中，比如`rt.jar`。
2. 扩展类加载器(Extension ClassLoader)：加载`$JAVA_HOME/lib/ext/`目录或者被`java.ext.dirs`系统环境变量所指定的路径中的所有类库。
3. 应用程序类加载器(Application ClassLoader)：这货就是`getSystemClassLoader()`方法的返回值。

#### 双亲委派模型

如下`java.lang.ClassLoader.loadClass()`方法源码：

``` java
    protected Class<?> loadClass(String name, boolean resolve)
        throws ClassNotFoundException
    {
        synchronized (getClassLoadingLock(name)) {
            // First, check if the class has already been loaded
            Class c = findLoadedClass(name);
            if (c == null) {
                long t0 = System.nanoTime();
                try {
                    if (parent != null) {
                        c = parent.loadClass(name, false);
                    } else {
                        c = findBootstrapClassOrNull(name);
                    }
                } catch (ClassNotFoundException e) {
                    // ClassNotFoundException thrown if class not found
                    // from the non-null parent class loader
                }

                if (c == null) {
                    // If still not found, then invoke findClass in order
                    // to find the class.
                    long t1 = System.nanoTime();
                    c = findClass(name);

                    // this is the defining class loader; record the stats
                    sun.misc.PerfCounter.getParentDelegationTime().addTime(t1 - t0);
                    sun.misc.PerfCounter.getFindClassTime().addElapsedTimeFrom(t1);
                    sun.misc.PerfCounter.getFindClasses().increment();
                }
            }
            if (resolve) {
                resolveClass(c);
            }
            return c;
        }
    }
```

#### 破坏双亲委派模型

1. 作为经常被用户调用的基础类，有时候可能会调用回用户的代码，比如JNDI服务，JDBC等。
   
   线程上下文类加载器(Thread Context ClassLoader)，通过`Thread.setContextClassLoader()` 方法设置。
   
2. 用户对程序动态性的追求导致，如热部署，模块热替换等。



## 虚拟机字节码执行引擎

### 栈帧

1. 每一个方法从调用开始至执行完成的过程，都对应着一个栈帧在虚拟机中入栈到出栈的过程。
2. 每一个栈帧包括了局部变量表，操作数栈，动态连接，发放返回地址和一些额外的附加信息。
3. 栈顶才是有效的，称为当前栈帧(Current Stack Frame)  / (Current Method)

#### 局部变量表

1. 局部变量表的容量以变量槽(Variable Slot)为最小单位。
2. reference类型表示一个对象实例的引用，其需要做到2点：(1). 从此引用中直接或间接的查找到对象在Java堆中的数据存放的起始地址索引。(2). 此引用直接或间接地查找到对象所属类型数据在方法区中的存储的类型信息，否则无法实现Java语言中定义的语法约束(反射)。
3. 对于64位的数据类型，JVM以高位对齐的方式为其分配两个连续的Solt空间，比如long, double。
4. 方法执行时，JVM使用局部变量表完成参数值到参数变量列表的传递过程。比如(非static方法)局部变量表中第0个Slot默认用于传递所属对象的实例，通过关键字`this`来访问到这个隐含参数，其余函数形参从1开始分配。
5. 局部变量表的Slot可以重用，通过作用于实现无用的Slot复用，GC回收时以Slot对应的变量是否有引用来判断是否回收。在合适的情况下，没用的变量置为`null`，并不是硬行推广的准则，看情况而定。

#### 操作数栈

1. 一个方法开始执行时，操作数栈为空，在方法执行时，各种字节码指令往操作数栈中写入和提取内容，即出/入栈操作。
2. 两个栈帧，作为虚拟机栈的元素，是完全独立的，但是很多JVM在实现的时候，为了避免方法调用开销过大，会令两个栈帧出现一部分重叠的情况。
3. Java虚拟机的解释执行引擎称为“基于栈的执行引擎”，这儿的栈就是操作数栈

#### 动态链接

#### 方法返回地址

两种方式退出方法：

1. 正常通过方法返回的字节码指令返回：正常完成出口
2. 异常：异常完成出库

无论何种退出，都需要返回到调用者的地方，这个地址需要保存，或者方法返回时要能够找到。

### 方法调用

#### 解析

1. 类在加载时，可以将静态方法，私有方法，实例构造器，父类方法，final修饰的方法，这些方法的引用可以确认唯一的调用版本，可以将这些方法的符号引用解析为方法的直接引用，此为非虚方法。
2. 无法在类加载时确定直接引用的，为虚方法。

#### 分配

多态在JVM的实现

##### 静态分配  重载

如下在一个类中的重载code：

``` java
public class Main {

    static class Human {
    }

    static class Man extends Human {
    }

    static class Woman extends Human {
    }

    public void sayHello(Human human) {
        System.out.println("Hello human");
    }

    public void sayHello(Man man) {
        System.out.println("Hello man");
    }

    public void sayHello(Woman woman) {
        System.out.println("Hello woman");
    }

    public static void main(String args[]) {
        Main main = new Main();
        Human man = new Man();
        Human woman = new Woman();
        main.sayHello(man);
        main.sayHello(woman);
    }
}
```

输出结果: 

``` java
Hello human
Hello human
```

1. `Human man = new Man()`，Human 为静态类型或者外观类型，Man为动态类型或者实际类型。
2. 编译器只能确定静态类型，动态类型无法确定，应为后面可能会有改动，如`man = new Woman()`。
3. JVM在重载时通过参数的静态类型，而不是动态类型作为判断依据的，因此在编译期Javac根据参数的静态类型决定使用哪个重载版本，直接写到了字节指令中。
4. 静态分配：所有依赖静态类型来定位方法执行版本的分派动作。方法重载就是个典型的使用例子。
5. 出现一对多，根据语法规则等找到“更合适的”，基本类型之间会自动转换，按照顺序`char->int->long->float->double`转换，如果还没有匹配，会自动装箱去尝试匹配，如果还没有则找起父类或者父接口类型。
6. 类型的自动转换以安全的转型为基础，如果碰到优先级一致的，则拒绝编译。

##### 动态委派  重写

根据动态类型实时定位方法执行版本，重写使用。

##### 单分派与多分派

1. 方法的接受者和参数统称为宗量。
2. 根据一个宗量对目标方法进行选择为单分配。
3. 根据多个宗量对目标方法进行选择为多分配。
4. 目前idk，包括idk 1.8，Java语言是一门静态多分配，动态单分配的语言。
5. 类的方法表存储在方法区，一般在类加载的连接阶段初始化完成。

#### 动态类型语言支持

1. idk 1.7添加指令`invokedynamic`。
2. 变量无类型而变量值才有类型是动态类型语言的一个重要特征。

## 知识点

### HotSpot虚拟机传参方式

以-XX开头的非稳定参数，传参方式有3种：

1. `-XX:+<option>`  开启option参数
2. `-XX:-<option>` 关闭option参数
3. `-XX:<option>=<value>` 讲option参数的值设置为value

给JVM传参，通过`System.getProperty(key)`获取对应的值，起设置`-D<key>=<value>`, 如下

``` java
-Dtq_search.local.port=8080
System.getProperty("tq_search.local.port")
```

