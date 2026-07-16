# OmniStudio Field Validation Suite

A reusable Apex field-validation library (email, US phone, US ZIP code) exposed to Salesforce OmniStudio as Integration Procedures, plus an OmniScript demo (`ContactUsDemo`) that wires all three into a working two-step form.

## Apex classes (`force-app/main/default/classes`)

| Class | Purpose |
|---|---|
| `EmailValidationService` | `isValidEmail()` / `normalizeEmail()` — regex-based email validation that rejects consecutive/leading dots and other malformed patterns. |
| `PhoneFormatService` | `isValidUSPhone()` / `formatUSPhone()` — validates and formats US phone numbers, including NANP structural checks (area code / exchange code can't start with 0 or 1). |
| `ZipCodeLookupService` | `lookupZipCode()` — validates a US ZIP (including ZIP+4) and looks up city/state via a live HTTP callout to the [Zippopotam.us](https://api.zippopotam.us) API. |
| `FieldValidationIPBridge` | Bridges the three services above to OmniStudio by implementing `System.Callable`, so it can be invoked as a Remote Action / Integration Procedure Action from an Integration Procedure or OmniScript. |

Each service class has a matching `*Test` class with 100% code coverage.

## OmniStudio Integration Procedures

Three Integration Procedures wrap the bridge for use from any OmniScript:

- `ValidateEmailIP_Default` — input `emailInput` → output `isValid`, `normalizedEmail`
- `ValidatePhoneIP_Default` — input `phoneInput` → output `isValid`, `formattedPhone`
- `ValidateZipCodeIP_Default` — input `zipInput` → output `isValid`, `city`, `state`, `stateAbbreviation`

Invoked via:

```apex
omnistudio.IntegrationProcedureService.runIntegrationService(
    'ValidateEmailIP_Default',
    new Map<String, Object>{ 'emailInput' => 'test@example.com' },
    new Map<String, Object>()
);
```

These Integration Procedures and the `ContactUsDemo` OmniScript are configured directly in the org (OmniStudio metadata) and are not part of this source-controlled Apex package.

## Repository contents

This repo tracks the Apex layer only — the OmniStudio Integration Procedures and OmniScript are org configuration (`OmniProcess` / `OmniProcessElement` records), not deployable source files, and are not included here.

## Requirements

- Salesforce CLI
- An org with the OmniStudio managed package installed (namespace `omnistudio`)
