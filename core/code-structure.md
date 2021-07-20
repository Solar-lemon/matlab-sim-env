## Code structure

Last update : 2021/07/20

Author : Sangmin Lee



#### Directory structure

* variables
  * Variable
  * StateVariable
  * TimeVaryingVariable
* functions
  * BaseFunction
  * DiscreteFunction
* systems
  * BaseSystem
  * TimeVaryingDynSystem
  * DynSystem
  * MultiStateDynSystem
  * MultipleSystem



#### Variable Classes

* Variable
  * properties : shape, value, flatValue
  * methods : numel
* StateVariable < Variable
  * properties
    * shape, value, flatValue (inherit)
    * useBaseFunction, derivFun, deriv, flatDeriv
  * methods
    * numel (inherit)
    * attachDerivFun, forward
* TimeVaryingVariable < Variable
  * properties
    * shape, value, flatValue (inherit)
    * useBaseFunction, shapingFun
  * methods
    * numel (inherit)
    * forward



#### Function Classes

* BaseFunction (abstract)
  * methods
    * forward (abstract)
* DiscreteFunction < BaseFunction
  * properties : useBaseFunction, fun, time, timer, output
  * methods
    * forward (implement)
    * reset, applyTime



#### System Classes

* BaseSystem
  * properties
    * time, stateVarList, stateVarNum, stateNum, stateIndex, logTimer, name, flag, state, stateValueList
  * methods
    * reset, applyState, applyTime, stateDeriv, startLogging, finishLogging
    * output, checkStopCondition, saveHistory (to be implemented)
    * indexing, stateFlatValue (protected)
    * forward (abstract)
* TimeVaryingDynSystem < BaseSystem
  * properties
    * time, stateVarList, stateVarNum, stateNum, stateIndex, logTimer, name, flag, state, stateValueList (inherit)
    * initialState, inValues, history, outputFun, stateVar
  * methods
    * applyTime, startLogging, finishLogging, indexing (inherit)
    * reset, applyState, stateDeriv, stateFlatValue (override)
    * attachDerivFun, attachOutputFun, saveSimData, loadSimData, plot
    * derivative, checkStopCondition (to be implemented)
    * forward, output, saveHistory (implement)
* DynSystem < TimeVaryingDynSystem
  * properties
    * time, stateVarList, stateVarNum, stateNum, stateIndex, logTimer, name, flag, state, stateValueList, initialState, inValues, history, outputFun, stateVar (inherit)
  * methods
    * reset, attachDerivFun, attachOutputFun, applyState, startLogging, finishLogging, stateDeriv, indexing, stateFlatValue, saveHistory, saveSimData, loadSimData, plot (inherit)
    * derivative, checkStopCondition (to be implemented)
    * forward, output (override)
* MultiStateDynSystem < BaseSystem
  * properties
    * time, stateVarList, stateVarNum, stateNum, stateIndex, logTimer, name, flag, state, stateValueList (inherit)
    * initialState, inValues, history, derivFun, outputFun
  * methods
    * applyState, applyTime, startLogging, finishLogging, stateDeriv, indexing, stateFlatValue (inherit)
    * reset (override)
    * attachDerivFun, attachOutputFun
    * derivative, checkStopCondition (to be implemented)
    * forward, output, saveHistory (implement)
* MultipleSystem < BaseSystem
  * properties
    * time, stateVarList, stateVarNum, stateNum, stateIndex, logTimer, name, flag, state, stateValueList (inherit)
    * systemList, systemNum, discSystemList, discSystemNum
  * methods
    * applyState, startLogging, finishLogging, indexing, stateFlatValue  (inherit)
    * reset, applyTime, stateDeriv (override)
    * attachDynSystems, attachDiscSystems
    * forward, output (to be implemented)
    * checkStopCondition, saveHistory (implement)



#### Simulator class

* Simulator
  * properties
    * initialized, system, stateNum
  * methods
    * startLogging, finishLogging, step, propagate





