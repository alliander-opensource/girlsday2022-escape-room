In order to create a layout for the nodes change `tree.dot` and use the following command

```bash
twopi -Tplain tree.dot | grep -v stop | cut -d ' ' -f 1,2,3,4 | ./scale.py
```