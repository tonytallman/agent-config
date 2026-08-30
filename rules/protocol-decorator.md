# Protocol decorator

When adding functionality to protocol instances:

- If the new behavior works equally well on **any instance of the protocol**, decorate the instance. Do not add it to every conformer and do not subclass to intercept.
- If the behavior is specific to one concrete type, add it to that type (or extract a protocol first, then decorate).
- For the implementation, follow the **protocol-decorator** skill.
