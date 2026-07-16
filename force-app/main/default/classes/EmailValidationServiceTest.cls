@isTest
private class EmailValidationServiceTest {

    @isTest
    static void testIsValidEmail_standardEmail_returnsTrue() {
        Boolean result = EmailValidationService.isValidEmail('test@example.com');
        System.assertEquals(true, result, 'Standard email "test@example.com" should be valid.');
    }

    @isTest
    static void testIsValidEmail_plusSignEmail_returnsTrue() {
        Boolean result = EmailValidationService.isValidEmail('test+alias@example.com');
        System.assertEquals(true, result, 'Email with a plus sign "test+alias@example.com" should be valid.');
    }

    @isTest
    static void testIsValidEmail_subdomainEmail_returnsTrue() {
        Boolean result = EmailValidationService.isValidEmail('user@mail.example.com');
        System.assertEquals(true, result, 'Email with a subdomain "user@mail.example.com" should be valid.');
    }

    @isTest
    static void testIsValidEmail_noAtSymbol_returnsFalse() {
        Boolean result = EmailValidationService.isValidEmail('test.example.com');
        System.assertEquals(false, result, 'Email with no "@" symbol should be invalid.');
    }

    @isTest
    static void testIsValidEmail_noDomain_returnsFalse() {
        Boolean result = EmailValidationService.isValidEmail('test@');
        System.assertEquals(false, result, 'Email with no domain after "@" should be invalid.');
    }

    @isTest
    static void testIsValidEmail_domainWithoutDot_returnsFalse() {
        Boolean result = EmailValidationService.isValidEmail('test@example');
        System.assertEquals(false, result, 'Email whose domain has no "." should be invalid.');
    }

    @isTest
    static void testIsValidEmail_noLocalPart_returnsFalse() {
        Boolean result = EmailValidationService.isValidEmail('@example.com');
        System.assertEquals(false, result, 'Email with no characters before "@" should be invalid.');
    }

    @isTest
    static void testIsValidEmail_noAtSymbolWithDot_returnsFalse() {
        Boolean result = EmailValidationService.isValidEmail('test.com');
        System.assertEquals(false, result, 'String with no "@" symbol at all should be invalid, even if it contains a dot.');
    }

    @isTest
    static void testIsValidEmail_consecutiveDotsInDomain_returnsFalse() {
        Boolean result = EmailValidationService.isValidEmail('test@example..com');
        System.assertEquals(false, result, 'Email with consecutive dots ".." in the domain should be invalid.');
    }

    @isTest
    static void testIsValidEmail_leadingDotInLocalPart_returnsFalse() {
        Boolean result = EmailValidationService.isValidEmail('.test@example.com');
        System.assertEquals(false, result, 'Email with a leading dot in the local part should be invalid.');
    }

    @isTest
    static void testIsValidEmail_nullInput_returnsFalse() {
        Boolean result = EmailValidationService.isValidEmail(null);
        System.assertEquals(false, result, 'Null input should be invalid.');
    }

    @isTest
    static void testIsValidEmail_blankInput_returnsFalse() {
        Boolean result = EmailValidationService.isValidEmail('   ');
        System.assertEquals(false, result, 'Blank/whitespace-only input should be invalid.');
    }

    @isTest
    static void testIsValidEmail_emptyStringInput_returnsFalse() {
        Boolean result = EmailValidationService.isValidEmail('');
        System.assertEquals(false, result, 'Empty string input should be invalid.');
    }

    @isTest
    static void testNormalizeEmail_mixedCaseWithWhitespace_trimsAndLowercases() {
        String result = EmailValidationService.normalizeEmail('  Test.User+Alias@Example.COM  ');
        System.assertEquals(
            'test.user+alias@example.com',
            result,
            'normalizeEmail should trim surrounding whitespace and lowercase the entire address.'
        );
    }

    @isTest
    static void testNormalizeEmail_nullInput_returnsNull() {
        String result = EmailValidationService.normalizeEmail(null);
        System.assertEquals(null, result, 'normalizeEmail should return null for null input.');
    }

    @isTest
    static void testNormalizeEmail_blankInput_returnsNull() {
        String result = EmailValidationService.normalizeEmail('   ');
        System.assertEquals(null, result, 'normalizeEmail should return null for blank input.');
    }
}
