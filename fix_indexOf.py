import re

with open('src/lib.mo', 'r') as f:
    text = f.read()

text = re.sub(
    r'switch\(List\.indexOf<Listener<T>>\(listeners, func\(a: Listener<T>, b: Listener<T>\) : Bool \{ Text\.equal\(a\.0, b\.0\) \}, listener\)\s*Text\.equal\(a\.0, b\.0\);\s*\}\)\)\{',
    r'switch(List.indexOf<Listener<T>>(listeners, func(a: Listener<T>, b: Listener<T>) : Bool { Text.equal(a.0, b.0) }, listener)){',
    text
)

with open('src/lib.mo', 'w') as f:
    f.write(text)
