// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ScientificMath.sol";

contract TestScientificMath {

    function test() public pure returns (ScientificMath.SciNumber memory) {
        // new 2 SciNumber
        ScientificMath.SciNumber memory a = ScientificMath.SciNumber(5e76, 100); 

        ScientificMath.SciNumber memory b = ScientificMath.sciNumber(3e55); 

        ScientificMath.SciNumber memory result = ScientificMath.add(a, b);
        // ScientificMath.SciNumber memory result = ScientificMath.sub(a, b);
        // ScientificMath.SciNumber memory result = ScientificMath.mul(a, b);
        // ScientificMath.SciNumber memory result = ScientificMath.div(a, b);
        
        return result;  
    }
}
