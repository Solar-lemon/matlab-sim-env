## Standard First-Order Dynamic

##### 2021/06/12

*Written by Sang-min Lee*

The transfer function for the standard first-order system is given as
$$
\frac{y(s)}{u(s)} = \frac{1}{\tau s + 1}
$$
where $\tau$ is the time constant. The above function can be re-arranged to give a differential equation as following
$$
\begin{align*}
\tau sy(s)+y(s) &= u(s) \\
\tau\dot{y} + y &= u
\end{align*}
$$
Let us define $x=y$. Then we obtain the following state-space model
$$
\begin{align*}
\dot{x} &= -\frac{1}{\tau}x + \frac{1}{\tau}u \\
y &= x
\end{align*}
$$
