---
title: 【八股文】Spring ＆ SpringBoot面试题
date: 2025-8-11 23:17:31    
tags:
  - Spring Boot
categories:
  - 面试准备    
description: 【八股文】Spring ＆ SpringBoot面试题
---

#### 1. Spring Boot 自动配置的原理是什么?

- Spring Boot 通过 `@EnableAutoConfiguration` **注解**启动自动配置功能；
- 底层用 **Spring Factories机制** （spring.factories / spring-autoconfigure-metadata）加载大量 `XXXAutoConfiguration` 类；
- 这些配置类内部通过 **条件注解** （如 `@ConditionalOnClass` ,`@ConditionalOnMissingBean` ）来决定是否生效；
- 简单来说：**如果类路径上存在某个依赖，并且用户没有自己定义Bean，Spring Boot就会帮你自动装配默认的Bean。**

###### 面试回答示例：
Spring Boot的自动配置本质上是基于**条件注解 + SPI 机制**  实现的。它会扫描类路径下的依赖，根据是否存在某些类、是否已经注册Bean来决定是否装配默认配置。例如，项目引入了Spring MVC依赖，Spring Boot就会通过 `WebMvcAutoConfiguration` 自动配置 `DispatcherServlet` 。这样我们只需要写最少的配置代码，就能启动一个应用。

SPI是什么？
SPI（Service Provider Interface）机制，直译为 **服务接口提供者**。
它是一种 解耦的插件发现机制：
- 框架或接口 定义一组规范（接口/抽象类）；
- 具体的实现者（第三方库、依赖包）提供实现类；
- 运行时，框架通过 **配置文件 + 类加载器** 动态加载这些实现类，而不是写死在代码里。

换句话说：
SPI = 我只约定接口，具体实现你自己提供，系统在运行时帮我找到并加载

#### 2. IOC和AOP的理解？在你的项目里是怎么用到的?

IOC（控制反转）
- 核心思想：把对象的创建和依赖关系的管理交给容器，不需要自己手动new。
- 例子：在项目里，用 `@Autowired`注入Service、DAO，而不是自己去new对象。

AOP（面向切面编程）
- 核心思想：把一些横切关注点（日志、事务、安全校验）从业务逻辑中剥离出来。
- 底层原理：基于 **动态代理（JDK Proxy / CGLIB）**
- 例子：Spring 的事务就是典型的AOP应用。

###### 面试回答示例：
IOC可以理解为「**谁依赖谁，谁控制谁**」。我们在项目里用IOC管理了Service和DAO的依赖关系，避免了硬编码；
AOP就是把日志、权限、事务等通用逻辑从业务逻辑中解耦。我在订餐项目中接触过Spring的事务管理，就是通过AOP动态代理来实现的；在认证流程里，其实拦截器也可以算一种切面编程思想的体现。

#### 3. 拦截器和过滤器的区别？在认证流程中为什么选择拦截器?

过滤器
- 属于Servlet规范，在Servlet容器中执行，作用范围更大；
- 可以在请求进入DispatcherServlet前做预处理，比如编码、跨域处理；
- 对Spring框架无感知

拦截器
- 属于**Spring MVC 框架**，更贴近业务逻辑；
- 可以拿到 **Controller 的上下文信息**（比如 handlerMethod、参数）；
- 生命周期更灵活：`preHandle`（调用前）、`postHandle`（调用后）、`afterCompletion`（请求完成）。

在认证流程中选择拦截器的原因：
- 认证需要获取 Controller 层的用户上下文，而过滤器无法感知具体哪个 Controller 被调用；
- 拦截器能方便地结合 **ThreadLocal** 保存用户信息（比如解析 JWT 之后保存用户 ID），整个请求生命周期都可以拿到；
- 实际项目中，我就在点餐系统里用拦截器 + ThreadLocal 来解析 JWT，避免每个 Controller 重复写认证逻辑。

