---
title: Java常用集合
date: 2025-11-17 23:00:00
tags:
  - Java
categories:
  - 八股文
description: Java常用集合
---

### 第一层：两大顶层接口
1. `Collection`接口：它是"单身"元素的集合，用于存储一组独立的对象。
2. `Map`接口：它是“成对”元素的集合，用于存储Key-Value键值对。

### 第二层：`Collection` 的三大核心子接口
`Collection`接口下面又派生出三个核心的子接口，它们定义了不同集合的“规矩”：`List`、`Set`和`Queue`。

1. List 列表
	- 核心特点：有序（按插入顺序）、可重复
	- 常用实现：
		- ArrayList：它的底层是动态数组。特点是查询快（O(1)因为有索引）；但增删慢O(n)，尤其是在中间插入或删除时，需要批量移动元素。
		- LinkedList：它的底层是双向链表。特点是增删快（O(1)），只需要改变前后节点的指针；但**查询慢**（O(n)），需要从头或尾遍历。
2. Set 集合
	- 核心特点：不可重复。它主要用于元素去重。
	- 常用实现：
		- HashSet：它的底层其实是一个HashMap（只用了Key）。特点是无序，增删查都非常快（O(1)）。它依赖元素的 `hashCode()` 和 `equals()` 方法来保证唯一性。
		- TreeSet：它的底层是红黑树。特点是它能自动排序（自然排序或自定义比较器），增删查性能稳定（O(logn)）。
		- LinkedHashSet：它结合了HashSet和LinkedList，既能像HashSet一样保证唯一性，又能维持插入顺序。
3. Queue 队列
	- 核心特点：先进先出（FIFO）
	- 常用实现：
		- LinkedList：它也实现了Queue接口，可以当队列用。
		- ArrayDeque：一个更高效的双端队列，既可以做队列（FIFO），也可以做栈（LIFO）使用，性能比LinkedList更好。
### 第三层：`Map` 的核心实现
Map接口存储的是键值对，它的Key是唯一的（类似于Set）。
- HashMap：底层是哈希表（数组+链表/红黑树）。它无序，增删查极快（O(1))。它是线程不安全的。
- TreeMap：底层是红黑树。它能根据Key自动排序。
- LinkedHashMap：它能维持插入顺序，或者访问顺序（这使它非常适合用来实现LRU（Least Recently Used最近最少使用）缓存）。

### 第四层：并发

以上提到的 ArrayList、HashMap等都是线程不安全的。在多线程环境下，我们必须使用java.util.concurrent(JUC)包下的并发集合。
- ConcurrentHashMap：（并发重点）替代HashMap，它通过CAS 和分段锁（或java 8后的synchronized优化）实现了高效的并发读写，是面试必问的。
- CopyOnWriteArrayList：替代ArrayList，它适用于“读多写少”的场景。写入时会复制一份新数组，所以写很慢，但读操作完全不加锁，非常快。

### 追问

#### 追问一：HashMap的内部实现

**面试官**：你提到了 HashMap 在 Java8 中是“数组 + 链表/红黑树”的结构。能详细讲讲这个结构吗？比如，**什么时候用链表**，**什么时候会转换成红黑树**？转换的“阈值”是多少？

回答：是的。HashMap内部维护一个Node类型的数组，我们称之为“桶”(bucket)。
1. 当我们`put`一个键值对时，它会先用Key的`hashCode()` 计算出一个哈希值，然后通过一个扰动函数和“与”运算（ &(n-1)）来定位到数组的具体索引。
2. 冲突与链表：如果这个位置是空的，就直接放入。如果这个位置已经有元素了（即哈希冲突），Java 8 会采用尾插法在这个桶上形成一个链表。
3. 树化（链表 -> 红黑树）：HashMap并不会让这个链表无限长下去，因为链表过长，查询效率会从O(1)退化到O(n)。它有两个关键阈值：
	- **`TREEIFY_THRESHOLD` (阈值 8)：** 当**同一个桶**中的链表长度达到 **8** 时，它**不一定**会立刻转红黑树。
	- **`MIN_TREEIFY_CAPACITY` (阈值 64)：** 它会先检查**整个数组的容量**。如果数组容量小于 **64**，它会选择**优先扩容 (resize)**，而不是树化。因为它认为，冲突过多是因为数组太小，扩容分散一下就好了。
	- **总结：** 只有当数组容量**大于等于64**，**且**链表长度达到**8**时，这个链表才会真正转换成红黑树，将查询效率优化到 O(log n)。

补充追问：那么红黑树会退化回链表吗？

回答：会的。当我们在 `remove` 元素，导致红黑树的节点数减少到 **`UNTREEIFY_THRESHOLD` (阈值 6)** 时，它会重新退化为链表，以节省空间。

#### 追问二：HashSet 与 HashMap的关系

面试官：你还提到HashSet的底层其实是一个HashMap，这是什么意思？HashSet是如何利用HashMap来保证元素"唯一且无序"的？

回答：
HashSet实际上是HashMap的一个”马甲“或者说适配器。
你看 `HashSet` 的源码就会发现，它内部持有一个 `private transient HashMap<E,Object> map;` 成员。
1. 保证唯一性：当我们调用 `set.add(element)` 时，它在底层实际执行的是 `map.put(element, PRESENT)`。
2. PRESENT是什么？`PRESENT` 是 `HashSet` 内部的一个静态的、私有的 `Object` 哑巴对象 (Dummy Object)，所有 Key 共享这一个 Value。
3. 如何工作：`HashMap` 的 `put` 方法会返回旧的 Value。如果 `put` 返回 `null`，说明这个 Key（也就是我们的 `element`）在 `map` 中不存在，于是 `set.add()` 方法就返回 `true`（表示添加成功）。如果 `put` 返回非 `null`（也就是返回 `PRESENT`），说明 Key 已存在，`HashMap` 会覆盖旧值，但 `set.add()` 会返回 `false`（表示添加失败，因为已存在）。

所以，`HashSet` 巧妙地利用了 `HashMap` 的 **Key 不可重复**的特性，来实现 `Set` 的元素唯一性。而它元素的无序性，也是完全继承自 `HashMap` Key 的无序性。

#### 追问三：并发安全与锁机制

面试官：你最后提到了并发集合，特别点了 `ConcurrentHashMap`。那你能对比一下 `HashMap`、`Hashtable` 和 `ConcurrentHashMap`（Java 8）在线程安全上的实现和性能差异吗？

回答：
这是一个很好的问题，这三者代表了Java并发Map的进化史。
1. `HashMap` (非安全)：
	- **实现：** 它是**线程不安全**的。
	- **问题：** 在多线程下 `put` 可能会导致数据覆盖或丢失；在扩容（resize）时，Java 7 中的头插法甚至可能导致链表**死循环**，造成CPU 100%。
2. `Hashtable` (已过时)：
	- **实现：** 它是线程安全的。
	- **问题：** 它实现安全的方式非常“暴力”，它在**几乎所有**的 public 方法上（如 `put`, `get`, `remove`, `size`）都加了 `synchronized` 关键字。
	- **性能：** 这相当于给**整个 `Map` 对象**加了一把大锁。同一时间只允许一个线程访问，其他所有线程（无论读写）都必须阻塞等待。在并发环境下，性能极低，锁竞争非常激烈。
3. `ConcurrentHashMap` (Java 8+) (高性能)：
	- **实现：** 它是线程安全的，并且性能极高。
	- **锁机制：** 它抛弃了 `Hashtable` 的全局锁，也抛弃了 Java 7 的分段锁 (Segment)。
	- **它在 Java 8 中使用了 `CAS` + `synchronized` 的精细化锁：**
    - **`put` 流程：**
        - **无冲突：** 如果计算出的数组桶位置是空的，它会使用 **`CAS`**（无锁）操作尝试放入新节点。
        - **有冲突：** 如果桶不为空，它会锁住**这个桶的头节点**——注意，是**只锁这一个桶**——在 Java 8 中它使用的是 `synchronized` 关键字来锁住这个头节点。
    - **`get` 流程：** `get` 操作几乎是**完全无锁**的，它利用了 `volatile` 关键字来保证内存可见性，所以读操作非常快。

**性能差异总结：**

- `Hashtable` 是**锁住整张表**，所有线程串行执行。
- `ConcurrentHashMap` (Java 8) 是**只锁住需要的那个桶**，其他线程可以同时访问其他几百个桶，并发度极高。