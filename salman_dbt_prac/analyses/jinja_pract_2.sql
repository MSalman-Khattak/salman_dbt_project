{% set fruit = ["apple", "banana", "orange", "grapes", "kiwi", "mango", "watermelon", "papaya", "pear", "peach", "plum", "cherry", "strawberry", "blueberry", "raspberry", "blackberry", "coconut", "pomegranate", "guava", "lychee"] %}

{% for i in fruit %}
    {%if i!="apple"%}
        {{i}}
    {%endif%}   
{% endfor %}