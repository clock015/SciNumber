// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ScientificMath
 * @dev Library for handling scientific notation arithmetic operations with uint256
 * Provides basic math operations (add, sub, mul, div) while maintaining precision
 * through normalized scientific notation representation
 */
library ScientificMath {

    /**
     * @dev Scientific notation number representation
     * @param mantissa Significand in range [1, 1e30)
     * @param exponent Power of 10 multiplier (base 10 exponent)
     */
    struct SciNumber {
        uint256 mantissa;  // Significand (normalized between 1 and 1e30)
        uint256 exponent;  // Base 10 exponent
    }

    /**
     * @notice Normalize existing SciNumber to canonical form
     * @dev Ensures mantissa is within [1, 1e35) range by adjusting exponent
     * @param number Input SciNumber to normalize
     * @return Normalized SciNumber with proper mantissa/exponent ratio
     */
    function sciNumber(SciNumber memory number) public pure returns (SciNumber memory) {
        // Reduce mantissa until below 1e35 threshold
        while (number.mantissa > 1e35) {
            number.mantissa /= 10;
            number.exponent++;
        }
        return SciNumber(number.mantissa, number.exponent);
    }

    /**
     * @notice Convert uint256 to normalized SciNumber
     * @dev Finds optimal exponent to represent number in scientific notation
     * @param number Integer to convert
     * @return Normalized SciNumber representation
     */
    function sciNumber(uint256 number) public pure returns (SciNumber memory) {
        uint256 exponent = 0;
        // Reduce number until below 1e30 threshold
        while (number > 1e30) {
            number /= 10;
            exponent++;
        }
        return SciNumber(number, exponent);
    }

    /**
     * @notice Add two SciNumbers (a + b)
     * @dev Aligns exponents before adding significands
     * @param a_ First operand
     * @param b_ Second operand
     * @return result Normalized sum of inputs
     */
    function add(SciNumber memory a_, SciNumber memory b_) internal pure returns (SciNumber memory) {
        SciNumber memory a = sciNumber(a_);
        SciNumber memory b = sciNumber(b_);

        if (a.exponent > b.exponent) {
            uint256 diff = a.exponent - b.exponent;
            if(diff > 31){
                return SciNumber(a.mantissa, a.exponent);
            }
            return SciNumber(a.mantissa + b.mantissa / (10**diff), a.exponent);
        } else if (a.exponent < b.exponent) {
            uint256 diff = b.exponent - a.exponent;
            return SciNumber(a.mantissa / (10**diff) + b.mantissa, b.exponent);
        } else {
            return SciNumber(a.mantissa + b.mantissa, a.exponent);
        }
    }

    /**
     * @notice Subtract two SciNumbers (a - b)
     * @dev Aligns exponents before subtracting significands
     * @param a Minuend
     * @param b Subtrahend
     * @return result Normalized difference of inputs
     */
    function sub(SciNumber memory a, SciNumber memory b) internal pure returns (SciNumber memory) {
        if (a.exponent > b.exponent) {
            uint256 diff = a.exponent - b.exponent;
            return SciNumber(a.mantissa - b.mantissa / (10**diff), a.exponent);
        } else if (a.exponent < b.exponent) {
            uint256 diff = b.exponent - a.exponent;
            return SciNumber(a.mantissa / (10**diff) - b.mantissa, b.exponent);
        } else {
            return SciNumber(a.mantissa - b.mantissa, a.exponent);
        }
    }

    /**
     * @notice Multiply two SciNumbers (a × b)
     * @dev Multiplies significands and sums exponents
     * @param a_ First factor
     * @param b_ Second factor
     * @return result Normalized product of inputs
     */
    function mul(SciNumber memory a_, SciNumber memory b_) internal pure returns (SciNumber memory) {
        SciNumber memory a = sciNumber(a_);
        SciNumber memory b = sciNumber(b_);

        uint256 newMantissa = a.mantissa * b.mantissa;
        uint256 newExponent = a.exponent + b.exponent;
        return sciNumber(SciNumber(newMantissa, newExponent));
    }

    /**
     * @notice Divide two SciNumbers (a ÷ b)
     * @dev Handles precision preservation for large exponent differences
     * @param a_ Dividend
     * @param b_ Divisor (must have non-zero significand)
     * @return result Normalized quotient of inputs
     * Requirements:
     * - `b_.mantissa` must be non-zero
     */
    function div(SciNumber memory a_, SciNumber memory b_) internal pure returns (SciNumber memory) {
        require(b_.mantissa != 0, "Cannot divide by zero");
        SciNumber memory a = sciNumber(a_);
        SciNumber memory b = sciNumber(b_);

        if (a.exponent > b.exponent) {
            uint256 diff = a.exponent - b.exponent;
            // Preserve precision for large exponent differences
            if(diff >= 40){
                return sciNumber(SciNumber(a.mantissa * (10**40) / b.mantissa, diff - 40));
            }
            return sciNumber(SciNumber(a.mantissa * (10**diff) / b.mantissa, 0));
            
        } else if (a.exponent < b.exponent) {
            uint256 diff = b.exponent - a.exponent;
            return SciNumber(a.mantissa / (10**diff) / b.mantissa, 0);
        } else {
            return SciNumber(a.mantissa / b.mantissa, 0);
        }
    }
}