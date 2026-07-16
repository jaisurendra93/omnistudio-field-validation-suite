/**
 * Standalone utility class that looks up a US ZIP code against the free,
 * no-signup, no-API-key Zippopotam.us public API and returns the city/state
 * it belongs to (if it exists).
 *
 * This class makes a REAL external HTTP callout to https://api.zippopotam.us
 * and requires an active Remote Site Setting for that host. In this org, that
 * Remote Site Setting already exists and is named "ZipCodes".
 */
public with sharing class ZipCodeLookupService {

    private static final String ZIPPOPOTAM_BASE_URL = 'https://api.zippopotam.us/us/';
    private static final Integer CALLOUT_TIMEOUT_MS = 10000;

    /**
     * Result of a ZIP code lookup. isValid indicates whether the ZIP code
     * actually exists according to Zippopotam.us; city/state/stateAbbreviation
     * are only populated when isValid is true.
     */
    public class ZipLookupResult {
        public Boolean isValid;
        public String city;
        public String state;
        public String stateAbbreviation;

        public ZipLookupResult() {
            // Boolean member variables default to null in Apex, not false,
            // so this must be set explicitly to guarantee a real false value.
            this.isValid = false;
        }
    }

    /**
     * Looks up a US ZIP code via the Zippopotam.us API.
     *
     * @param zipCode the ZIP code to look up
     * @return a ZipLookupResult describing whether the ZIP code exists and,
     *         if so, the city/state/state abbreviation it belongs to
     */
    public static ZipLookupResult lookupZipCode(String zipCode) {
        ZipLookupResult result = new ZipLookupResult();

        if (String.isBlank(zipCode)) {
            return result;
        }

        // Trim surrounding whitespace so " 94103 " is treated the same as "94103".
        String candidateZip = zipCode.trim();

        // ZIP+4 support: if the trimmed input is a 5-digit base ZIP followed by
        // a hyphen and 4 more digits (e.g. "94103-1234"), strip the "-XXXX"
        // suffix and look up just the 5-digit base ZIP code.
        if (candidateZip.length() == 10 && candidateZip.substring(5, 6) == '-'
            && candidateZip.substring(0, 5).isNumeric() && candidateZip.substring(6, 10).isNumeric()) {
            candidateZip = candidateZip.substring(0, 5);
        }

        // Cheap, simple format check before spending a callout: must be
        // exactly 5 numeric characters. This does NOT confirm the ZIP code
        // actually exists - that's what the callout below is for - it just
        // avoids wasting a callout on obviously unusable input.
        if (candidateZip.length() != 5 || !candidateZip.isNumeric()) {
            return result;
        }

        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ZIPPOPOTAM_BASE_URL + candidateZip);
            request.setMethod('GET');
            request.setTimeout(CALLOUT_TIMEOUT_MS);

            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                // Parse the JSON body and pull city/state info out of the
                // first entry in the "places" array.
                Map<String, Object> parsedBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> places = (List<Object>) parsedBody.get('places');

                if (places != null && !places.isEmpty()) {
                    Map<String, Object> firstPlace = (Map<String, Object>) places.get(0);
                    result.city = (String) firstPlace.get('place name');
                    result.state = (String) firstPlace.get('state');
                    result.stateAbbreviation = (String) firstPlace.get('state abbreviation');
                    result.isValid = true;
                }
            } else if (response.getStatusCode() == 404) {
                // Expected, normal "ZIP code does not exist" case - not an
                // error. result.isValid is already false from the constructor.
            } else {
                // Any other status code is unexpected; treat as not-found
                // rather than throwing, but log it so it's visible in debug logs.
                System.debug('ZipCodeLookupService: unexpected status code ' + response.getStatusCode()
                    + ' looking up ZIP ' + candidateZip + '. Body: ' + response.getBody());
            }
        } catch (Exception ex) {
            // Covers timeouts, malformed/unparseable JSON, or any other
            // unexpected failure. Never let the exception propagate to the
            // caller - just log it and report the ZIP as not valid.
            System.debug('ZipCodeLookupService: error looking up ZIP ' + candidateZip + ' - ' + ex.getMessage());
        }

        return result;
    }
}
