/* This is an experiment practice of creating my own test macro. 
   Note: from the learning, user always needs to add a "test_" as prefix in front of the script name.
 */
{% test udf_not_null(model, column_name) %}

    select *
    from {{ model }}
    where {{ column_name }} is null
    or {{ column_name }} = ''

{% endtest %}