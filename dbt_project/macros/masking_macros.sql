{% macro hash_pii_sha256(column_name) %}
    -- Casts to string and hashes via SHA-256 for irreversible PII tokenization
    encode(digest(CAST({{ column_name }} AS VARCHAR), 'sha256'), 'hex')
{% endmacro %}

{% macro mask_string_partial(column_name) %}
    -- Keeps the first character, masks the rest (e.g., "Ali Rezaei" -> "A***")
    CONCAT(SUBSTRING(TRIM({{ column_name }}), 1, 1), '***')
{% endmacro %}
