## Bearings-Only Measurement IACG

##### 2021/09/10

Reference: H. G. Kim, J. Y. Lee, and H. J. Kim, "Look Angle Constrained Impact Angle Control Guidance Law for Homing Missiles With Bearings-Only Measurements", *IEEE Transactions on Aerospace and Electronic Systems* 54.6 (2018): 3096-3107.



#### Equations of motion

The planar engagement against a stationary target is considered.
$$
\begin{align}
\dot{R} &= -V_{M}\cos\sigma_{M} \\
\dot{\lambda} &= - \frac{V_{M}}{R}\sin\sigma_{M} \\
\dot{\gamma}_{M} &= \frac{a_{M}}{V_M}
\end{align}
$$
where $R$ is the relative range, $V_{M}$ is the speed of the missile, $\sigma_{M}$ is the seeker's look angle, $\lambda$ is the LOS angle and $\gamma_{M}$​ is the flight path angle of the missile.



#### Guidance law

Define $e_{1}$ and $e_{2}$ as
$$
\begin{align}
e_{1} &= \lambda - \gamma_{d} \\
e_{2} &= \sigma_{M}
\end{align}
$$
The sliding surface $S(\sigma_{M}, \lambda)$ is defined as
$$
S(\sigma_{M}, \lambda)=e_{2} - k_{1}\textrm{sgmf}(e_{1})
$$
where the sigmoid function $\textrm{sgmf}(\cdot)$ is defined as
$$
\textrm{sgmf}(x) = \frac{x}{\sqrt{x^2 + \phi^2}}
$$
Design parameters $k_{1}$ and $\phi$​ are chosen as
$$
0 < k_{1} < \sigma_{M}^{\max} < \frac{\pi}{2},\quad \phi > 0
$$
The sliding mode guidance law is defined as
$$
a_{M}=-\left( \frac{V_{M}}{R_{f}}f_{2}(\sigma_{M}, \lambda) + k_{2} \right)V_{M}\textrm{tanh}(aS)
$$
where
$$
\begin{align}
f_{2}(\sigma_{M}, \lambda) &= \left( 1 + k_{1}\frac{\partial}{\partial e_{1}}\textrm{sgmf}(e_{1}) \right)\vert \sin\sigma_{M} \vert \\
&= \left( 1 + k_{1}\frac{\phi^{2}}{(e_{1}^{2} + \phi^{2})^{3/2}} \right)\vert \sin\sigma_{M} \vert

\end{align}
$$
and $\textrm{tanh}(\cdot)$ is used instead of $\textrm{sgn}(\cdot)$​​ to avoid the chattering caused by the discontinuity.

 