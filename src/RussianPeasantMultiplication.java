public class RussianPeasantMultiplication
{
    // get the minimum
    // div the min by 2 (can shift left by one)
    // multiply the other by 2
    // if minimum is odd, add m to the result
    // until min reaches 1

    /**
     * Handles non-negatives only
     */
    private static long rpMult(long m, long n)
    {
        // m is max
        // n is min
        long sum = 0;

        while (n >= 1)
        {
            // checking the base with bitwise &
            // even is 0
            if ((n & 1) == 1) // if odd
                sum += m;

            m <<= 1; // multiply m by 2

            n >>= 1; // div n by 2
        }

        return sum;
    }

    /**
     * Handles negatives
     */
    public static long rpMultiply(long m, long n)
    {
        boolean ismNegative = m < 0,
                isnNegative = n < 0;

        long sign = ((m < 0) ^ (n < 0)) ? -1 : 1;

        m = ismNegative ? m * -1 : m;
        n = isnNegative ? n * -1 : n;

        long min = Math.min(m, n);
        long max = Math.max(m, n);

        if (max == 0 || min == 0) return 0;

        long result = rpMult(max, min);

        // negatives is 0 --> no negatives
        // negatives is 1 --> there is one negative, multiply result by -1
        // negative is 2 --> return result
        return sign * result;
    }

    private static int parseInt(String s, String varName)
    {
        // s to parse
        // varname is n or m

        int val = 0;
        try
        {
            val = Integer.parseInt(s);
        }  catch (NumberFormatException e)
        {
            System.err.println("Error: Invalid value '" + s +
                    "' for integer " + varName + ".");
            System.exit(1);
        }

        return val;
    }

    public static void main(String[] args)
    {
        if (args.length != 2)
        {
            System.err.println("Usage: java RPMult <integer m> <integer n>");
            System.exit(1);
        }

        int m = parseInt(args[0], "m");
        int n = parseInt(args[1], "n");

        long result = rpMultiply(m , n);

        System.out.println(args[0] + " x " + args[1] + " = " + result);
    }
}
