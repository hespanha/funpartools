# FunParTools

## Table of Contents

* [Description](# Description)
* [Installation](# Installation)
* [Usage](# Usage)
* [Contact Information](# Contact Information)
* [Licence Information](# Licence Information)

## Description

The FunParTools Matlab toolbox is part of the TensCalc Matlab toolbox
but is useful on its own right. It provides functions to

1. declare 'named' inputs to a matlab function of the form:
	f('variable 1',value 1,'variable 2',value 2, ...)

2. set default values for inputs not provided (optional)

3. test if the input values fall within admissible sets (optional)

4. automatically generate 'help' from declared inputs

5. automatically saving output/input values to files with an
   accompanying "pedigree" file that described the parameters used to
   generate the outputs (optional)

6. bypass function execution if the function has been previously
   called with the same parameters and the outputs were saved (optional)

This toolbox is mostly useful when 

1. writing functions with many input arguments to simplify calling the
   function with "default" inputs
   
	and/or

2. writing scripts that do batch processing of large data sets with
   multiple steps (each affected by parameters) to minimize calling
   functions whose inputs have not changed

## Installation

1. Download the toolbox which should contain, at least, the following folder

  * funpartools/lib
  * funpartools/examples

2. Add `funpartools/lib` to your matlab path. 
   From inside the folder `funpartools/lib`, this can be done with

	``` matlab
	addpath(fileparts(which('declareParameter')));
	savepath
	```

3. To test if all is well, go to `funpartools/examples` and execute

	``` matlab
	createMatrix help
	testFlow
	```
	
## Usage

Matlab functions that use FunParTools take the following general form:

	``` matlab
    function [varargout]=functionName(varargin)
    % For help on the input parameters type 'functionName Help'
    
      % Function global help
      declareParameter(...
          'Help', { '...' })
    
      % Declare all input parameters, see 'help declareParameter'
      declareParameter( .... );
    
      % Declare all output parameters, see 'help declareOutput'
      declareOutput( .... );
    
      % Retrieve parameters and inputs
      [stopNow,params]=setParameters(nargout,varargin);
      if stopNow
         return;
      end
    
      % Start main code here
    
        ....
    
      % Set outputs
      vargout=setOutputs(nargout,params);
    
    end
    ```

This function is then called using the syntax:

    ``` matlab
    	[output1,output2,...]=functionName('input1',value1,'input2',value2,...);
    ```

The function's documentation can be obtained using the following syntax:

    ``` matlab
    	functionName help
    ```

The function's latex-formated documentation can be obtained using the
following syntax. This also produces a file with the latex-formated
documentation with the same name as the function, but with the
extension .tex (instead of .m).

    ``` matlab
    	createGateway help latex
    ```

FunParTools contains its own documentation embedded into the matlab
scripts. To see it, type at the matlab prompt:

    ``` matlab
    help setParameters
    help declareParameter
    help declareOutput
    ```

## Contact Information

Joao Hespanha
hespanha@ucsb.edu

http://www.ece.ucsb.edu/~hespanha
University of California, Santa Barbara
	
## Licence Information

Copyright 2010-2017 Joao Hespanha

This file is part of Tencalc.

TensCalc is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

TensCalc is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with TensCalc.  If not, see <http://www.gnu.org/licenses/>.

