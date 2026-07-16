/**
 * Standalone utility class providing US phone number formatting and validation
 * for use in OmniStudio Integration Procedures / OmniScripts.
 *
 * Scoped to US phone numbers only: 10-digit numbers, or 11-digit numbers with a
 * leading US country code "1". No international handling, no external callouts.
 */
public with sharing class PhoneFormatService {

    // Matches the canonical "(XXX) XXX-XXXX" shape produced by formatUSPhone().
    // Used by isValidUSPhone() to check the result without re-deriving digit counts.
    private static final Pattern FORMATTED_PHONE_PATTERN = Pattern.compile('^\\(\\d{3}\\) \\d{3}-\\d{4}$');

    /**
     * Formats a raw phone number string into "(XXX) XXX-XXXX" if it resolves to
     * a valid 10-digit US number. Otherwise returns the original input unchanged
     * (or null for null/blank input).
     *
     * @param rawPhone the raw phone number string to format
     * @return the formatted phone number, the original input, or null
     */
    public static String formatUSPhone(String rawPhone) {
        if (String.isBlank(rawPhone)) {
            return null;
        }

        // Strip every character that is not a digit (spaces, dashes, parens,
        // dots, plus signs, etc.) so only the raw digit sequence remains.
        String digitsOnly = rawPhone.replaceAll('[^0-9]', '');

        String tenDigits;
        if (digitsOnly.length() == 10) {
            // Exactly 10 digits: this is already a bare US number.
            tenDigits = digitsOnly;
        } else if (digitsOnly.length() == 11 && digitsOnly.startsWith('1')) {
            // 11 digits with a leading "1" is a US number with its country code
            // included (e.g. "1-415-555-0100"). Strip the leading "1" to get the
            // same 10-digit shape as the branch above.
            tenDigits = digitsOnly.substring(1);
        } else {
            // Any other digit count (too few, too many, or 11 digits not
            // starting with "1") is not a US number this method can confidently
            // format, so the original raw input is returned unchanged.
            return rawPhone;
        }

        if (!hasValidNanpStructure(tenDigits)) {
            // Right digit count, but the area code or exchange code starts with
            // 0 or 1, which is not structurally valid under the North American
            // Numbering Plan. Treat this the same as any other invalid input.
            return rawPhone;
        }

        return formatTenDigits(tenDigits);
    }

    /**
     * Basic North American Numbering Plan (NANP) structural check on a 10-digit
     * number: the area code (digits 1-3) and the exchange code (digits 4-6) must
     * not start with '0' or '1'. Intentionally limited to just these two checks
     * (no reserved-code or N11 handling).
     */
    private static Boolean hasValidNanpStructure(String tenDigits) {
        String areaCodeFirstDigit = tenDigits.substring(0, 1);
        String exchangeCodeFirstDigit = tenDigits.substring(3, 4);

        if (areaCodeFirstDigit == '0' || areaCodeFirstDigit == '1') {
            return false;
        }

        if (exchangeCodeFirstDigit == '0' || exchangeCodeFirstDigit == '1') {
            return false;
        }

        return true;
    }

    /**
     * Indicates whether formatUSPhone() would successfully produce a formatted
     * "(XXX) XXX-XXXX" result for the given input. Reuses formatUSPhone() itself
     * rather than re-implementing the digit-counting logic.
     *
     * @param rawPhone the raw phone number string to validate
     * @return true if the input resolves to a valid 10-digit US number
     */
    public static Boolean isValidUSPhone(String rawPhone) {
        String formatted = formatUSPhone(rawPhone);
        if (formatted == null) {
            return false;
        }

        return FORMATTED_PHONE_PATTERN.matcher(formatted).matches();
    }

    /**
     * Builds the "(XXX) XXX-XXXX" string from a string that is known to be
     * exactly 10 digits long.
     */
    private static String formatTenDigits(String tenDigits) {
        String areaCode = tenDigits.substring(0, 3);
        String prefix = tenDigits.substring(3, 6);
        String lineNumber = tenDigits.substring(6, 10);
        return '(' + areaCode + ') ' + prefix + '-' + lineNumber;
    }
}
