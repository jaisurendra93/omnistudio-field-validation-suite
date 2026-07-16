/**
 * OmniStudio Remote Action bridge for the field validation library's
 * Integration Procedures (ValidateEmailIP, ValidatePhoneIP, ValidateZipCodeIP).
 *
 * Implements System.Callable, the interface this org's OmniStudio Remote
 * Action runtime actually requires for a "remoteClass" reference (confirmed
 * via a live runtime error: "Apex class needs to implement System.Callable").
 * Dispatches by action name to the existing, already-tested
 * EmailValidationService, PhoneFormatService, and ZipCodeLookupService
 * classes - none of which are modified by this bridge. This class contains
 * NO business logic of its own beyond reading inputs and delegating.
 *
 * Inputs are read via String.valueOf() rather than a direct (String) cast,
 * since a misconfigured OmniScript field can hand this class a non-String
 * JSON value (number, boolean); a direct cast throws System.TypeException,
 * while String.valueOf() converts it to its string form (and passes null
 * through as null) so the request still reaches normal validation instead
 * of erroring out.
 */
global with sharing class FieldValidationIPBridge implements System.Callable {

    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> inputMap = (Map<String, Object>) args.get('input');
        Map<String, Object> outMap = (Map<String, Object>) args.get('output');

        try {
            if (action == 'validateEmail') {
                // String.valueOf() safely converts any non-null input (e.g. a
                // JSON number or boolean from a misconfigured OmniScript field)
                // to its string form instead of throwing on a direct cast, and
                // preserves null as null.
                String emailInput = String.valueOf(inputMap.get('emailInput'));
                outMap.put('isValid', EmailValidationService.isValidEmail(emailInput));
                outMap.put('normalizedEmail', EmailValidationService.normalizeEmail(emailInput));
                return true;
            } else if (action == 'validatePhone') {
                String phoneInput = String.valueOf(inputMap.get('phoneInput'));
                outMap.put('isValid', PhoneFormatService.isValidUSPhone(phoneInput));
                outMap.put('formattedPhone', PhoneFormatService.formatUSPhone(phoneInput));
                return true;
            } else if (action == 'validateZipCode') {
                String zipInput = String.valueOf(inputMap.get('zipInput'));
                ZipCodeLookupService.ZipLookupResult zipResult = ZipCodeLookupService.lookupZipCode(zipInput);
                outMap.put('isValid', zipResult.isValid);
                outMap.put('city', zipResult.city);
                outMap.put('state', zipResult.state);
                outMap.put('stateAbbreviation', zipResult.stateAbbreviation);
                return true;
            } else {
                // "bridgeError" (not "error") - the platform's own Remote
                // Action response envelope already reserves the "error" key
                // for its own "OK"/failure status, so reusing it here would
                // silently overwrite that field.
                outMap.put('isValid', false);
                outMap.put('bridgeError', 'Unknown action: ' + action);
                return false;
            }
        } catch (Exception ex) {
            outMap.put('isValid', false);
            outMap.put('bridgeError', ex.getMessage());
            return false;
        }
    }
}
