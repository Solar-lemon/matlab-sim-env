## Composite Guidance for IAC

##### 2021/08/19

Reference: B. Park, H. Kwon, Y. Kim, and T. Kim, "Composite guidance scheme for impact angle control against a nonmaneuvering moving target." *Journal of Guidance, Control, and Dynamics* 39.5 (2016): 1132-1139.



#### Equations of motion

The subscripts $M$ and $T$ represent the missile and target.
$$
\begin{align}
\dot{r} &= V_{T}\cos(\gamma_{T} - \lambda) - V_{M}\cos(\gamma_{M} - \lambda) \\
r\dot{\lambda} &= V_{T}\sin(\gamma_{T} - \lambda) - V_{M}\sin(\gamma_{M} - \lambda) \\
\dot{\gamma}_{M} &= \frac{a_{M}}{V_{M}} \\
\sigma &= \gamma_{M} - \lambda
\end{align}
$$
where $r$ is the relative range, $\gamma$ is the flight path angle, $\lambda$ is the LOS angle and $\sigma$ is the seeker's look angle.



#### Composite guidance scheme

The composite guidance for impact angle control is composed of two phases.

* Phase 1 : look angle control guidance (modified deviated pure pursuit) during $\vert \lambda \vert < \vert \lambda_{s} \vert$​.
* Phase 2 : proportional navigation guidance during $\vert \lambda \vert \ge \vert \lambda_{s} \vert$​.

In phase 1, the acceleration command is given as
$$
a_{M} = V_{M}\dot{\lambda} + K(\sigma_{d} - \sigma)
$$
In phase 2, the acceleration command is given as
$$
a_{M} = NV_{M}\dot{\lambda}
$$


#### Switching condition

Under PNG,
$$
\dot{\gamma}_{M} = N\dot{\lambda},\quad \dot{\sigma} = \dot{\gamma}_{M} - \dot{\lambda} = (N-1)\dot{\lambda}
$$
and
$$
\gamma_{M_{f}}-\gamma_{M} = N(\lambda_{f} - \lambda), \quad \sigma_{f} - \sigma = (N- 1)(\lambda_{f} - \lambda)
$$
Therefore,
$$
\begin{align}
\lambda_{s} &= \lambda_{f} - \frac{\sigma_{f} - \sigma_{s}}{N - 1} = \lambda_{f} - \frac{\gamma_{M_{f}} - \lambda_{f} - \sigma_{s}}{N - 1} = \frac{N}{N-1}\lambda_{f} - \frac{\gamma_{M_{f}} - \sigma_{s}}{N - 1} \\
&= \frac{N}{N - 1}\left(\lambda_{f} - \frac{\gamma_{M_{f}} - \sigma_{s}}{N - 1} \right)
\end{align}
$$
Meanwhile, using the collision condition $\dot{\lambda}=0$,
$$
\begin{align}
& V_{T}\sin(\gamma_{T_{f}} - \lambda_{f}) - V_{M}\sin(\gamma_{M_{f}} - \lambda_{f}) = 0 \\
& \therefore \lambda_{f} = \tan^{-1}\left( \frac{\sin \gamma_{M_{f}} - \eta \sin \gamma_{T}}{\cos\gamma_{M_{f}} - \eta \cos \gamma_{T}} \right)
\end{align}
$$
where the ratio of speeds $\eta$ is defined as $\eta = \frac{V_{T}}{V_{M}}$.

The switching condition for $\lambda$ can be expressed as
$$
\lambda_{s} = \frac{N}{N - 1}\left( \tan^{-1}\left(\frac{\sin \gamma_{M_{f}} - \eta\sin \gamma_{T}}{\cos\gamma_{M_{f}} - \eta\cos\gamma_{T}} \right) - \frac{\gamma_{M_{f}} - \sigma_{s}}{N} \right)
$$
