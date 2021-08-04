## Quadrotor Geometric Tracking Control

##### 2021/07/29

Contents of this document is based on the following reference:

T. Lee, M. Leok and N. H. McClamroch, "Geometric tracking control of a quadrotor UAV on SE(3)," in 49th IEEE Conference on Decision and Control, 2010.

T. Lee, M. Leok and N. H. McClamroch, "Geometric tracking control of a quadrotor UAV on SE(3)," arXiv:1003.2005v1. [Online]. Available: http://arxiv.org/abs/1003.2005v1.

T. Lee, "Geometric tracking control of the attitude dynamics of a rigid body on SO(3)", in Proceedings of the 2011 American Control Conference, 2011.



#### Attitude Tracking Control

Equations of the motion for the attitude dynamics are
$$
\begin{align*}
\dot{R} &= R\Omega^{\wedge} \\
\dot{\Omega} &= J^{-1}\left( -\Omega \times (J\Omega) + \tau \right)
\end{align*}
$$
The attitude error function and the attitude error vector are defined as
$$
\begin{align*}
\Psi \left( R, R_{d}\right) &:=\frac{1}{2}\tr \left( I - R_{d}^{T}R \right) \\
e_{R} &:= \frac{1}{2}\left( R_{d}^{T}R - R^{T}R_{d} \right)^{\vee}
\end{align*}
$$
Then,
$$
\begin{align*}
\frac{d}{d\epsilon}\Psi \left(R\exp(\epsilon\eta^{\wedge}), R_{d} \right)\Big\vert_{\epsilon=0} &= \frac{d}{d\epsilon}\frac{1}{2}\tr(I - R_{d}^{T}R\exp(\epsilon\eta^{\wedge})) \Big\vert_{\epsilon=0} \\
&= \frac{1}{2}\tr(-R_{d}^{T}R\exp(\epsilon\eta^{\wedge})\eta^{\wedge})\Big\vert_{\epsilon=0} \\
&= -\frac{1}{2}\tr(R_{d}^{T}R\eta^{\wedge}) \\
&= \frac{1}{2}\eta^{T}(R_{d}^{T}R - R^{T}R_{d})^{\vee} \\
&= \frac{1}{2}(R_{d}^{T}R - R^{T}R_{d})^{\vee}\cdot \eta = e_{R}\cdot \eta
\end{align*}
$$
Meanwhile, the angular velocity error vector is defined as
$$
e_{\Omega}:=\Omega - R^{T}R_{d}\Omega_{d}
$$
where
$$
\Omega_{d} =(R_{d}^{T}\dot{R}_{d})^{\vee}
$$
The relation between $e_{R}$ and $e_{\Omega}$​ can be found as
$$
\begin{align*}
\dot{e}_{R} &=\frac{1}{2}(\dot{R}_{d}^{T}R + R_{d}^{T}\dot{R} - \dot{R}^{T}R_{d} - R^{T}\dot{R}_{d})^{\vee} \\
&= \frac{1}{2}(R_{d}^{T}R(\Omega - R^{T}R_{d}\Omega_{d})^{\wedge} + (\Omega - R^{T}R_{d}\Omega_{d})^{\wedge}R^{T}R_{d})^{\vee} \\
&= \frac{1}{2}(R_{d}^{T}Re_{\Omega}^{\vee} + e_{\Omega}^{\vee}R^{T}R_{d})^{\wedge} \\
&= \frac{1}{2}(\tr(R^{T}R_{d})I - R^{T}R_{d})e_{\Omega} =: C(R, R_{d})e_{\Omega}
\end{align*}
$$
It can be shown that $\Vert C(R, R_{d})\Vert_{2} \le 1$ for any $R_{d}^{T}R \in SO(3)$​. Thus, $\Vert \dot{e}_{R}\Vert \le \Vert e_{\Omega}\Vert$.

The time derivative of $e_{\Omega}$ is given by
$$
\begin{align*}
\dot{e}_{\Omega} &= \dot{\Omega} - \dot{R}^{T}R_{d}\Omega_{d} - R^{T}\dot{R}_{d}\Omega_{d} - R^{T}R_{d}\dot{\Omega}_{d} \\
&= J^{-1}(-\Omega \times (J\Omega) + \tau) - (\Omega^{\wedge})^{T}R^{T}R_{d}\Omega_{d} - R^{T}R_{d}\Omega_{d}^{\wedge}\Omega_{d} - R^{T}R_{d}\dot{\Omega}_{d} \\
&= J^{-1}(-\Omega \times (J\Omega) + \tau) + \Omega^{\wedge}R^{T}R_{d}\Omega_{d} - R^{T}R_{d}\dot{\Omega}_{d}
\end{align*}
$$
where
$$
\dot{\Omega}_{d} = (\dot{R}_{d}^{T}\dot{R}_{d} + R_{d}^{T}\ddot{R}_{d})^{\vee}
$$


The control law for the attitude tracking is defined as
$$
\tau := -k_{R}e_{R} - k_{\Omega}e_{\Omega} + \Omega \times(J\Omega) - J(\Omega^{\wedge}R^{T}R_{d}\Omega_{d} - R^{T}R_{d}\dot{\Omega}_{d})
$$
which results in the error dynamics of
$$
J\dot{e}_{\Omega}=-k_{R}e_{R} - k_{\Omega}e_{\Omega}; \quad J\dot{e}_{\Omega} + k_{R}e_{R} + k_{\Omega}e_{\Omega} = 0
$$



#### Position Tracking Control

Equations of motion for the position dynamics are
$$
\begin{align*}
\dot{x} &= v \\
\dot{v} &= ge_{3} - \frac{1}{m}fRe_{3} = ge_{3} - \frac{1}{m}F
\end{align*}
$$
where the z-axis of the frame is along the direction of the gravity. The position error and velocity error are defined as
$$
e_{x} = x - x_{d},\quad e_{v} = v - v_{d}
$$
Let us define the right-hand side of the second equation as $u$. That is,
$$
u = ge_{3} - \frac{1}{m}fRe_{3} = ge_{3} - \frac{1}{m}F
$$
The desired value of $u$ is designed as
$$
u_{d}=-k_xe_x - k_ve_v + \ddot{x}_{d}
$$
Then, the desired value of $F=fRe_{3}$ can be determined from the relation
$$
\begin{align*}
ge_{3} - \frac{1}{m}F_{d} &= -k_{x}e_{x} - k_{v}e_{v} + \ddot{x}_{d} \\
\therefore F_{d} &= m \left(k_{x}e_{x} + k_{v}e_{v} + ge_{3} - \ddot{x}_{d} \right) 
\end{align*}
$$
The total thrust is determined as
$$
f = F_{d} \cdot z_{B} = F_{d} \cdot (Re_{3})
$$
where $z_{B}$ denotes the unit vector along the z-axis of the body frame. The desired orientation is determined as
$$
\begin{align*}
x_{C, d} &= \begin{bmatrix}
\cos\psi_{d} \\
\sin\psi_{d} \\
0
\end{bmatrix} \\
z_{B, d} &= \frac{F_{d}}{\Vert F_{d} \Vert} \\
y_{B, d} &= \frac{z_{B, d} \times x_{C, d}}{\Vert z_{B, d} \times x_{C, d} \Vert} \\
x_{B, d} &= y_{B, d} \times z_{B, d} \\
R_{d} &= \begin{bmatrix} x_{B, d} & y_{B, d} & z_{B, d} \end{bmatrix}
\end{align*}
$$
where $\psi_{d}$ is the desired heading angle (yaw angle) and $x_{B, d}, y_{B, d}, z_{B, d}$ denote unit vectors along the axes of the body frame.
