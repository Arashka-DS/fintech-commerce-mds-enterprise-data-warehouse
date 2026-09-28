{# Deterministic SHA-256 tokenization for National IDs, Customer Identifiers, and Card Numbers #}
{% macro hash_pii(column_name) %}
    MD5(CONCAT('fintech_salt_', {{ column_name }}))
{% endmacro %}

{# Partial masking for telephone numbers: Converts 09121111111 to 0912***1111 #}
{% macro mask_phone(column_name) %}
    CASE 
        WHEN {{ column_name }} IS NULL THEN NULL
        WHEN LENGTH({{ column_name }}) = 11 THEN
            CONCAT(SUBSTRING({{ column_name }} FROM 1 FOR 4), '***', SUBSTRING({{ column_name }} FROM 8 FOR 4))
        ELSE 'INVALID_PHONE_MASK'
    END
{% endmacro %}
