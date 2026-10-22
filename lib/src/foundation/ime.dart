/// Host-injected hook to suppress / restore the OS input method (IME).
///
/// base-ui carries **no platform code**. A desktop host wires this to its own
/// native layer (e.g. daro's `daro/ime` MethodChannel) so that masked
/// (password) fields can force raw keystrokes: without it, a Chinese/Japanese
/// IME composes pinyin *inside* the field and Flutter counts the uncommitted
/// composing text toward the masked dot count, so the number of dots no longer
/// matches what was actually typed.
///
/// [handler] is called with `true` when a masked field gains focus (suppress
/// the IME) and `false` when it loses focus (restore it). Left `null` (the
/// default) the feature is inert and `Input` behaves exactly as before — so
/// the component stays usable on platforms / hosts without an implementation.
class ImeSuppression {
  ImeSuppression._();

  static void Function(bool suppress)? handler;
}
