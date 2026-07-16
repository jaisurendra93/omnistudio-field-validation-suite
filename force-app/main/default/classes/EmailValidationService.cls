/**
 * Standalone utility class providing email format validation and normalization
 * for use in OmniStudio Integration Procedures / OmniScripts.
 *
 * This class performs FORMAT validation only. It does not verify deliverability,
 * perform DNS/MX lookups, or make any external callouts.
 */
public with sharing class EmailValidationService {

    /**
     * Regex pattern used to validate standard email formatting.
     *
     * Breakdown of the pattern: ^(?!.*\.\.)[^@\s.][^@\s]*@[^@\s.][^@\s]*\.[^@\s]+$
     *   ^                - start of string
     *   (?!.*\.\.)       - negative lookahead: fails the match if two consecutive
     *                      dots ".." appear anywhere in the string (e.g. rejects
     *                      "test@example..com")
     *   [^@\s.]          - the first character of the local part must not be '@',
     *                      whitespace, or '.' (rejects a leading dot, e.g.
     *                      ".test@example.com")
     *   [^@\s]*          - the rest of the local part: zero or more characters
     *                      that are NOT '@' and NOT whitespace (e.g. "est" in "test")
     *   @                - exactly one literal '@' symbol
     *   [^@\s.]          - the first character of the domain must not be '@',
     *                      whitespace, or '.' (rejects "test@.com")
     *   [^@\s]*          - the rest of the domain up to the final segment
     *                      (e.g. "example" or "mail.example")
     *   \.               - a literal dot separating the domain from its top-level part
     *   [^@\s]+          - one or more characters that are NOT '@' and NOT whitespace
     *                      (the final domain segment after the last dot, e.g. "com")
     *   $                - end of string
     *
     * Because the pattern requires a '@' and a '.' to each appear, and disallows
     * '@' from appearing in the local part or domain segments, this naturally
     * enforces "exactly one @ symbol" for the string to match as a whole.
     * The final "[^@\s]+" segment (after the last dot) guarantees there is at
     * least one character after the final dot, e.g. rejecting "test@example."
     */
    private static final String EMAIL_REGEX = '^(?!.*\\.\\.)[^@\\s.][^@\\s]*@[^@\\s.][^@\\s]*\\.[^@\\s]+$';
    private static final Pattern EMAIL_PATTERN = Pattern.compile(EMAIL_REGEX);

    /**
     * Checks whether the supplied string is a correctly formatted email address.
     * Does NOT check deliverability, DNS records, or mail server existence —
     * format validation only.
     *
     * @param email the string to validate
     * @return true if email is non-blank and matches the expected email format
     */
    public static Boolean isValidEmail(String email) {
        if (String.isBlank(email)) {
            return false;
        }

        Matcher emailMatcher = EMAIL_PATTERN.matcher(email);
        return emailMatcher.matches();
    }

    /**
     * Normalizes an email address by trimming surrounding whitespace and
     * converting it to lowercase. Performs no other transformation.
     *
     * @param email the string to normalize
     * @return the trimmed, lowercased email, or null if input is null/blank
     */
    public static String normalizeEmail(String email) {
        if (String.isBlank(email)) {
            return null;
        }

        return email.trim().toLowerCase();
    }
}
