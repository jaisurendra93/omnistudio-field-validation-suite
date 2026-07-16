@isTest
private class PhoneFormatServiceTest {

    @isTest
    static void testFormatUSPhone_plainDigits_returnsFormatted() {
        String result = PhoneFormatService.formatUSPhone('4155550100');
        System.assertEquals('(415) 555-0100', result, 'Plain 10-digit string should format to "(415) 555-0100".');
    }

    @isTest
    static void testFormatUSPhone_dashedFormat_returnsFormatted() {
        String result = PhoneFormatService.formatUSPhone('415-555-0100');
        System.assertEquals('(415) 555-0100', result, 'Dashed format should format to "(415) 555-0100".');
    }

    @isTest
    static void testFormatUSPhone_parenthesesFormat_returnsFormatted() {
        String result = PhoneFormatService.formatUSPhone('(415) 555-0100');
        System.assertEquals('(415) 555-0100', result, 'Already-parenthesized format should normalize to "(415) 555-0100".');
    }

    @isTest
    static void testFormatUSPhone_dottedFormat_returnsFormatted() {
        String result = PhoneFormatService.formatUSPhone('415.555.0100');
        System.assertEquals('(415) 555-0100', result, 'Dotted format should format to "(415) 555-0100".');
    }

    @isTest
    static void testFormatUSPhone_elevenDigitsWithLeadingOne_returnsFormatted() {
        String result = PhoneFormatService.formatUSPhone('14155550100');
        System.assertEquals('(415) 555-0100', result, '11-digit number with leading US country code "1" should strip it and format to "(415) 555-0100".');
    }

    @isTest
    static void testFormatUSPhone_tooFewDigits_returnsOriginalUnchanged() {
        String input = '5550100';
        String result = PhoneFormatService.formatUSPhone(input);
        System.assertEquals(input, result, 'Input with too few digits (7) should be returned unchanged since it cannot be confidently formatted.');
    }

    @isTest
    static void testFormatUSPhone_elevenDigitsNotStartingWithOne_returnsOriginalUnchanged() {
        String input = '24155550100';
        String result = PhoneFormatService.formatUSPhone(input);
        System.assertEquals(input, result, '11-digit input not starting with "1" should be returned unchanged.');
    }

    @isTest
    static void testFormatUSPhone_nullInput_returnsNull() {
        String result = PhoneFormatService.formatUSPhone(null);
        System.assertEquals(null, result, 'Null input should return null.');
    }

    @isTest
    static void testFormatUSPhone_blankInput_returnsNull() {
        String result = PhoneFormatService.formatUSPhone('   ');
        System.assertEquals(null, result, 'Blank/whitespace-only input should return null.');
    }

    @isTest
    static void testIsValidUSPhone_areaCodeStartsWithZero_returnsFalse() {
        Boolean result = PhoneFormatService.isValidUSPhone('0000000000');
        System.assertEquals(false, result, 'Area code starting with "0" fails the NANP structural check, so this should be invalid.');
    }

    @isTest
    static void testIsValidUSPhone_areaCodeStartsWithOne_returnsFalse() {
        Boolean result = PhoneFormatService.isValidUSPhone('1115550100');
        System.assertEquals(false, result, 'Area code starting with "1" fails the NANP structural check, so this should be invalid.');
    }

    @isTest
    static void testExchangeCodeStartsWithOne_returnsFalseAndUnchanged() {
        String input = '4151550100';
        Boolean validResult = PhoneFormatService.isValidUSPhone(input);
        System.assertEquals(false, validResult, 'Area code "415" is valid, but exchange code "155" starts with "1", which fails the NANP structural check, so this should be invalid.');

        String formattedResult = PhoneFormatService.formatUSPhone(input);
        System.assertEquals(input, formattedResult, 'An input that fails the exchange-code NANP check should be returned unchanged, same as any other invalid case.');
    }

    @isTest
    static void testIsValidUSPhone_validTenDigit_returnsTrue() {
        Boolean result = PhoneFormatService.isValidUSPhone('415-555-0100');
        System.assertEquals(true, result, 'A valid 10-digit US phone number should be considered valid.');
    }

    @isTest
    static void testIsValidUSPhone_validElevenDigitWithLeadingOne_returnsTrue() {
        Boolean result = PhoneFormatService.isValidUSPhone('14155550100');
        System.assertEquals(true, result, 'A valid 11-digit US phone number with leading "1" should be considered valid.');
    }

    @isTest
    static void testIsValidUSPhone_tooFewDigits_returnsFalse() {
        Boolean result = PhoneFormatService.isValidUSPhone('5550100');
        System.assertEquals(false, result, 'An input with too few digits should be considered invalid.');
    }

    @isTest
    static void testIsValidUSPhone_nullInput_returnsFalse() {
        Boolean result = PhoneFormatService.isValidUSPhone(null);
        System.assertEquals(false, result, 'Null input should be considered invalid.');
    }

    @isTest
    static void testIsValidUSPhone_blankInput_returnsFalse() {
        Boolean result = PhoneFormatService.isValidUSPhone('   ');
        System.assertEquals(false, result, 'Blank/whitespace-only input should be considered invalid.');
    }
}
