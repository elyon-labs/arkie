enum PrivateKeyReplacementReason { legacyPath, missing, unreadable, invalid }

enum PrivateKeyHealthStatus { checking, usable, replacementRequired }

sealed class PrivateKeyHealth {
  const PrivateKeyHealth();
}

class PrivateKeyChecking extends PrivateKeyHealth {
  const PrivateKeyChecking();
}

class PrivateKeyUsable extends PrivateKeyHealth {
  const PrivateKeyUsable();
}

class PrivateKeyReplacementRequired extends PrivateKeyHealth {
  const PrivateKeyReplacementRequired(this.reason);

  final PrivateKeyReplacementReason reason;
}
