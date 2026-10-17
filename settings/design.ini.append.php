<?php /* #?ini charset="utf-8"?

# The templates of the admin module "expqueue" live in design/admin/templates/expqueue/.
[ExtensionSettings]
DesignExtensions[]=expqueue

# The look of Setup > Job queue: the administration's shared components (.a4-*) and tokens (--a4-*), and what they
# cannot do in design/admin/stylesheets/expqueue.css (.a4-queue-*). No template carries inline CSS
# (tests/unit/StylingRulesTest.php).
[StylesheetSettings]
BackendCSSFileList[]=expqueue.css

# The question of a control that needs a confirmation (data-a4-confirm) in a design without admin4's a4_actions.js.
# No template carries an inline script or event handler attribute (tests/unit/ScriptRulesTest.php).
[JavaScriptSettings]
BackendJavaScriptList[]=expqueue_confirm.js

*/ ?>
