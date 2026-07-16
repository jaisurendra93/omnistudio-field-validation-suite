@isTest
private class ZipCodeLookupServiceTest {

    // Simulates a Zippopotam.us HTTP response with a given status code and body.
    private class ZipCodeMockResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        public ZipCodeMockResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            if (body != null) {
                response.setBody(body);
            }
            return response;
        }
    }

    // Fails the test loudly if a callout is ever attempted, so tests using
    // this mock can prove with certainty that no callout was made.
    private class FailIfCalledMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            System.assert(false, 'No HTTP callout should have been made for this input, but one was attempted to: ' + request.getEndpoint());
            return new HttpResponse();
        }
    }

    @isTest
    static void testLookupZipCode_validZip_returnsCityStateInfo() {
        String mockBody = '{"post code":"94103","country":"United States","country abbreviation":"US",'
            + '"places":[{"place name":"San Francisco","state":"California","state abbreviation":"CA",'
            + '"latitude":"37.7726","longitude":"-122.4099"}]}';
        Test.setMock(HttpCalloutMock.class, new ZipCodeMockResponse(200, mockBody));

        Test.startTest();
        ZipCodeLookupService.ZipLookupResult result = ZipCodeLookupService.lookupZipCode('94103');
        Test.stopTest();

        System.assertEquals(true, result.isValid, 'A 200 response with a places array should mark the result as valid.');
        System.assertEquals('San Francisco', result.city, 'City should be parsed from the "place name" field.');
        System.assertEquals('California', result.state, 'State should be parsed from the "state" field.');
        System.assertEquals('CA', result.stateAbbreviation, 'State abbreviation should be parsed from the "state abbreviation" field.');
    }

    @isTest
    static void testLookupZipCode_nonExistentZip_returnsInvalid() {
        Test.setMock(HttpCalloutMock.class, new ZipCodeMockResponse(404, null));

        Test.startTest();
        ZipCodeLookupService.ZipLookupResult result = ZipCodeLookupService.lookupZipCode('00000');
        Test.stopTest();

        System.assertEquals(false, result.isValid, 'A 404 response is a normal "not found" case and should result in isValid = false.');
        System.assertEquals(null, result.city, 'City should remain null for a non-existent ZIP code.');
    }

    @isTest
    static void testLookupZipCode_nonNumericInput_returnsInvalidWithoutCallout() {
        Test.setMock(HttpCalloutMock.class, new FailIfCalledMock());

        Test.startTest();
        ZipCodeLookupService.ZipLookupResult result = ZipCodeLookupService.lookupZipCode('ABC12');
        Test.stopTest();

        System.assertEquals(false, result.isValid, 'Non-numeric input should be rejected as invalid without attempting a callout.');
    }

    @isTest
    static void testLookupZipCode_tooShortInput_returnsInvalidWithoutCallout() {
        Test.setMock(HttpCalloutMock.class, new FailIfCalledMock());

        Test.startTest();
        ZipCodeLookupService.ZipLookupResult result = ZipCodeLookupService.lookupZipCode('123');
        Test.stopTest();

        System.assertEquals(false, result.isValid, 'A 3-digit input should be rejected as invalid without attempting a callout.');
    }

    @isTest
    static void testLookupZipCode_nullInput_returnsInvalidWithoutCallout() {
        Test.setMock(HttpCalloutMock.class, new FailIfCalledMock());

        Test.startTest();
        ZipCodeLookupService.ZipLookupResult result = ZipCodeLookupService.lookupZipCode(null);
        Test.stopTest();

        System.assertEquals(false, result.isValid, 'Null input should be rejected as invalid without attempting a callout.');
    }

    @isTest
    static void testLookupZipCode_emptyPlacesArray_returnsInvalidWithoutCrashing() {
        String mockBody = '{"post code":"99999","country":"United States","country abbreviation":"US","places":[]}';
        Test.setMock(HttpCalloutMock.class, new ZipCodeMockResponse(200, mockBody));

        Test.startTest();
        ZipCodeLookupService.ZipLookupResult result = ZipCodeLookupService.lookupZipCode('99999');
        Test.stopTest();

        System.assertEquals(false, result.isValid, 'A 200 response with an empty "places" array should not be treated as valid.');
        System.assertEquals(null, result.city, 'City should remain null when "places" is empty.');
    }

    @isTest
    static void testLookupZipCode_missingPlacesField_returnsInvalidWithoutCrashing() {
        String mockBody = '{"post code":"99999","country":"United States","country abbreviation":"US"}';
        Test.setMock(HttpCalloutMock.class, new ZipCodeMockResponse(200, mockBody));

        Test.startTest();
        ZipCodeLookupService.ZipLookupResult result = ZipCodeLookupService.lookupZipCode('99999');
        Test.stopTest();

        System.assertEquals(false, result.isValid, 'A 200 response missing the "places" field entirely should not be treated as valid.');
        System.assertEquals(null, result.city, 'City should remain null when "places" is missing.');
    }

    @isTest
    static void testLookupZipCode_serverError500_returnsInvalidSameAsNotFound() {
        Test.setMock(HttpCalloutMock.class, new ZipCodeMockResponse(500, 'Internal Server Error'));

        Test.startTest();
        ZipCodeLookupService.ZipLookupResult result = ZipCodeLookupService.lookupZipCode('99999');
        Test.stopTest();

        System.assertEquals(false, result.isValid, 'A 500 server error should result in isValid = false, the same outward result as a 404.');
    }

    @isTest
    static void testLookupZipCode_malformedJson_returnsInvalidWithoutThrowing() {
        String truncatedJson = '{"post code":"94103","places":[{"place name":"San Francisco",';
        Test.setMock(HttpCalloutMock.class, new ZipCodeMockResponse(200, truncatedJson));

        Test.startTest();
        ZipCodeLookupService.ZipLookupResult result = ZipCodeLookupService.lookupZipCode('94103');
        Test.stopTest();

        System.assertEquals(false, result.isValid, 'Malformed/unparseable JSON in a 200 response should be caught and return isValid = false, not throw.');
    }

    @isTest
    static void testLookupZipCode_placesIsNotAnArray_returnsInvalidWithoutThrowing() {
        String mockBody = '{"post code":"94103","country":"United States","country abbreviation":"US","places":"not-an-array"}';
        Test.setMock(HttpCalloutMock.class, new ZipCodeMockResponse(200, mockBody));

        Test.startTest();
        ZipCodeLookupService.ZipLookupResult result = ZipCodeLookupService.lookupZipCode('94103');
        Test.stopTest();

        System.assertEquals(false, result.isValid, 'A "places" field that is a string instead of an array should trigger a ClassCastException that is caught, not propagated, resulting in isValid = false.');
    }

    @isTest
    static void testLookupZipCode_zipPlusFourFormat_stripsSuffixAndReturnsCityStateInfo() {
        String mockBody = '{"post code":"94103","country":"United States","country abbreviation":"US",'
            + '"places":[{"place name":"San Francisco","state":"California","state abbreviation":"CA",'
            + '"latitude":"37.7726","longitude":"-122.4099"}]}';
        Test.setMock(HttpCalloutMock.class, new ZipCodeMockResponse(200, mockBody));

        Test.startTest();
        ZipCodeLookupService.ZipLookupResult result = ZipCodeLookupService.lookupZipCode('94103-1234');
        Test.stopTest();

        System.assertEquals(true, result.isValid, 'A ZIP+4 input should have its "-XXXX" suffix stripped and be looked up as a valid 5-digit ZIP.');
        System.assertEquals('San Francisco', result.city, 'City should be parsed the same as for the bare 5-digit ZIP.');
        System.assertEquals('California', result.state, 'State should be parsed the same as for the bare 5-digit ZIP.');
        System.assertEquals('CA', result.stateAbbreviation, 'State abbreviation should be parsed the same as for the bare 5-digit ZIP.');
    }
}
