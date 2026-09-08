# Adaptor

When bridging types at the composition root:

- If converting **one concrete source type** to a **different interface**, adapt it. Do not widen provider packages or add forbidden local dependencies to expose the target.
- If adding behavior that works on **any instance of a protocol**, decorate the instance instead. Do not use an adaptor for that.
- For the implementation, follow the **adaptor** skill.
