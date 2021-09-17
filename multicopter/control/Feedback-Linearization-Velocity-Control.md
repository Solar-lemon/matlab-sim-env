## Feedback Linearization Velocity Control

##### 2021/09/15

Contents of this document is based on the following reference:

H. Voos, "Nonlinear Control of a Quadrotor Micro-UAV using Feedback-Linearization", Proceedings of the 2009 IEEE International Conference on Mechatronics, 2009.



#### Simplified dynamic model

Equations of the motion for designing the controller are simplified as
$$
\begin{align}
\ddot{x} &= -(\cos\phi \sin\theta \cos\psi + \sin\phi \sin\psi)\frac{f}{m} \\
\ddot{y} &= -(\cos\phi \sin\theta \sin\psi - \sin\theta \cos\psi)\frac{f}{m} \\
\ddot{z} &= g - (\cos\phi \cos\theta)\frac{f}{m} \\
\ddot{\phi} &= \dot{\theta}\dot{\psi} \left( \frac{I_{y} - I_{z}}{I_{x}} \right) + \frac{\tau_{x}}{I_{x}} \\
\ddot{\theta} &= \dot{\phi}\dot{\psi} \left( \frac{I_{z} - I_{x}}{I_{y}} \right) + \frac{\tau_{y}}{I_{y}} \\
\ddot{\psi} &= \dot{\phi}\dot{\theta} \left( \frac{I_{x} - I_{y}}{I_{x}} \right) + \frac{\tau_{z}}{I_{z}}
\end{align}
$$
where $f$​ is the total thrust, $\tau_{x}, \tau_{y}, \tau_{z}$​​ are torques.

Define $x^{T}=(\dot{x}, \dot{y}, \dot{z}, \phi, \theta, \psi, \dot{\phi}, \dot{\theta}, \dot{\psi})$. Then,
$$
\dot{x} = 
\begin{bmatrix}
-(\cos x_{4} \sin x_{5} \cos x_{6} + \sin x_{4} \sin x_{6})\frac{f}{m} \\
-(\cos x_{4} \sin x_{5} \sin x_{6} - \sin x_{4} \cos x_{6})\frac{f}{m} \\
g - (\cos x_{4} \cos x_{5})\frac{f}{m} \\
x_{7} \\
x_{8} \\
x_{9} \\
x_{8}x_{9}I_{1} + \frac{\tau_{x}}{I_{x}} \\
x_{7}x_{9}I_{2} + \frac{\tau_{y}}{I_{y}} \\
x_{7}x_{8}I_{3} + \frac{\tau_{z}}{I_{z}}
\end{bmatrix}
$$
where $I_{1}=(I_{y} - I_{z})/I_{x}$, $I_{2}=(I_{z} - I_{x})/I_{y}$, $I_{3}=(I_{x} - I_{y})/I_{z}$.



#### Attitude control

Apply a feedback linearization
$$
\begin{align}
\tau_{x} &= I_{x}(-x_{8}x_{9}I_{1} + u_{2}^{\ast}) \\
\tau_{y} &= I_{y}(-x_{7}x_{9}I_{2} + u_{3}^{\ast}) \\
\tau_{z} &= I_{z}(-x_{7}x_{8}I_{3} + u_{4}^{\ast})
\end{align}
$$
Then we get
$$
\begin{align}
\dot{x}_{7} &= u_{2}^{\ast} \\
\dot{x}_{8} &= u_{3}^{\ast} \\
\dot{x}_{9} &= u_{4}^{\ast}
\end{align}
$$
Note that
$$
\dot{x}_{4} = x_{7};\quad\ddot{x}_{4}=u_{2}^{\ast}
$$
Application of PD control $u_{2}^{\ast} = k_{p, 2}(x_{4d} - x_{4}) - k_{d, 2}\dot{x}_{4}$​ leads to
$$
\ddot{x}_{4} + k_{d, 2}\dot{x}_{4} + k_{p, 2}x_{4} = k_{p, 2}x_{4d};\quad \frac{X_{4}(s)}{X_{4d}(s)} = \frac{k_{p, 2}}{s^{2} + k_{d,2}s + k_{p, 2}}
$$
A choice of $k_{d, 2}=80$ leads to a settling time of approximately $T_{s} \approx 0.1$ sec and a choice of $k_{p, 2}=(k_{d,2}/2)^{2}$​ leads to zero overshoot.

The same consideration hold for the other two angles.



#### Velocity control

The velocity dynamic can be expressed as
$$
\begin{align}
\dot{x}_{1} &= -(\cos x_{4d} \sin x_{5d} \cos x_{6d} + \sin x_{4d} \sin x_{6d})\frac{f}{m} = \tilde{u}_{1} \\
\dot{x}_{2} &= -(\cos x_{4d} \sin x_{5d} \sin x_{6d} - \sin x_{4d} \cos x_{6d})\frac{f}{m} = \tilde{u}_{2} \\
\dot{x}_{3} &= g - (\cos x_{4d} \cos x_{5d})\frac{f}{m} = \tilde{u}_{3}
\end{align}
$$
where $x_{4d}, x_{5d}, x_{6d}$​ are the desired attitude angles. Pure proportional control can be used for the system as
$$
\begin{align}
\tilde{u}_{1} &= k_{1}(x_{1d} - x_{1}) \\
\tilde{u}_{2} &= k_{2}(x_{2d} - x_{2}) \\
\tilde{u}_{3} &= k_{3}(x_{3d} - x_{3})
\end{align}
$$
It is obvious that any desired velocity vector can be achieved without any yaw rotation and $x_{6d}$​ can be set as zero.
$$
\begin{align}
\tilde{u}_{1} &= -\cos x_{4d}\sin x_{5d} \frac{f}{m} \\
\tilde{u}_{2} &= \sin x_{4d} \frac{f}{m} \\
\tilde{u}_{3} &= g - \cos x_{4d}\cos x_{5d} \frac{f}{m}
\end{align}
$$
Define the following substitution:
$$
\begin{align}
\alpha &= \sin x_{4d} \quad \Rightarrow \quad \cos x_{4d} = \sqrt{1 - \alpha^{2}} \quad \left( -\frac{\pi}{2} < x_{4d} < \frac{\pi}{2} \right) \\
\beta &= \sin x_{5d} \quad \Rightarrow \quad \cos x_{5d} = \sqrt{1 - \beta^{2}} \quad \left( -\frac{\pi}{2} < x_{5d} < \frac{\pi}{2} \right)
\end{align}
$$
For $\tilde{u}_{1} > 0$​, we obtain the following solution
$$
\begin{align}
\beta &= -\left(
1 + \left( \frac{g - \tilde{u}_{3}}{\tilde{u}_{1}} \right)^{2} \right)^{-1/2} \\
f &= m \sqrt{\left( \frac{\tilde{u}_{1}}{\beta} \right)^{2} + \tilde{u}_{2}^{2}} \\
\alpha &= \frac{m}{f}\tilde{u}_{2}
\end{align}
$$
For $\tilde{u}_{1} < 0$, we obtain the following solution
$$
\begin{align}
\beta &= \left(
1 + \left( \frac{g - \tilde{u}_{3}}{\tilde{u}_{1}} \right)^{2} \right)^{-1/2} \\
f &= m \sqrt{\left( \frac{\tilde{u}_{1}}{\beta} \right)^{2} + \tilde{u}_{2}^{2}} \\
\alpha &= \frac{m}{f}\tilde{u}_{2}
\end{align}
$$
For $\tilde{u}_{1}=0$, we obtain the following solution
$$
\begin{align}
\beta &= 0 \\
f &= m\sqrt{\tilde{u}_{2}^{2} + (g - \tilde{u}_{3})^{2}} \\
\alpha &= \frac{m}{f}\tilde{u}_{2}
\end{align}
$$
Finally,
$$
x_{4d} = \arcsin \alpha,\quad x_{5d} = \arcsin \beta
$$



#### Alternative formulation for the desired attitude angles

Let $x_{6d}=0$. Using the equations,
$$
\tilde{u}_{1}^{2} + \tilde{u}_{2}^{2} + (\tilde{u}_{3} - g)^{2} = \left( \frac{f}{m} \right)^{2} \quad \therefore f = m \sqrt{\tilde{u}_{1}^{2} + \tilde{u}_{2}^{2} + (\tilde{u}_{3} - g)^{2})}
$$
In addition,
$$
\begin{align}
x_{4d} &= \phi_{d} = \arcsin( \frac{m}{f}\tilde{u}_{2}) \\
x_{5d} &= \theta_{d} = \arctan( \frac{\tilde{u}_{1}}{\tilde{u}_{3} - g} )
\end{align}
$$






