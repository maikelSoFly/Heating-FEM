# Heating-FEM

**Heating simulation of a 4 scm thick oven door glass window made out of two heat-resistant BOROFLOAT® 33 - Borosilicate glass panes with a space between filled with argon**. Model is surrounded with room temperature from left-hand side and **250℃ (fan-forced)** from right-hand side. Glass panes have both **width of 6 nodes (5 elements)** in the grid, which is 5 mm.

To solve such problem I used **Finite Elements Method** and some additional algorithms like Gauss's Elimination.

###### All results are placed in _Results_ catalog.
---
### Fan-forced heating (alpha = ~19.45 W/m<sup>2</sup>K, duration: 10 min, time step: 3 sec):

<p align="center">
    <img src="https://raw.githubusercontent.com/maikelSoFly/Heating-FEM/master/Results/borofloat_simulations/fan_forced/fan-forced_animation_600sec.gif" width="550"/>
</p>

### Normal heating (alpha = ~9.03 W/m<sup>2</sup>K, duration: 10 min, time step: 3 sec):

<p align="center">
    <img src="https://raw.githubusercontent.com/maikelSoFly/Heating-FEM/master/Results/borofloat_simulations/normal/normal_animation_600sec.gif" width="550"/>
</p>
