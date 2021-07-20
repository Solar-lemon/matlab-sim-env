## Standard Second-Order Dynamic

##### 2021/06/21

*Written by Sang-min Lee*

The transfer function for the standard second-order system is given as
$$
\frac{y(s)}{u(s)}=\frac{\omega_{n}^{2}}{s^{2} + 2\zeta\omega_{n}s + \omega_{n}^{2}}
$$
where $\zeta$ is the damping ratio and $\omega_{n}$ is the natural frequency. The above function can be re-arranged to give a differential equation as following
$$
\begin{align*}
s^{2}y(s) + 2\zeta\omega_{n}sy(s) + \omega_{n}^{2}y(s) &= \omega_{n}^{2}u(s) \\
\ddot{y} + 2\zeta\omega_{n}\dot{y} + \omega_{n}^{2}y &= \omega_{n}^{2}u
\end{align*}
$$
Let us define $x_{1}=y, x_{2}=\dot{y}$. Then we obtain the following state-space model
$$
\begin{align*}
\begin{bmatrix}
\dot{x}_{1} \\ \dot{x}_{2}
\end{bmatrix} &=
\begin{bmatrix}
0 & 1 \\
-\omega_{n}^{2} & -2\zeta\omega_{n}
\end{bmatrix}
\begin{bmatrix}
x_{1} \\ x_{2}
\end{bmatrix} + \begin{bmatrix}
0 \\ \omega_{n}^{2}
\end{bmatrix}u \\

y &= \begin{bmatrix} 1 & 0 \end{bmatrix}
\begin{bmatrix} x_{1} \\ x_{2} \end{bmatrix}
\end{align*}
$$
