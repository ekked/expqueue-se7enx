<?php
/**
 * @copyright Copyright (C) 1998 - 2026 7x & Exponential Foundation. All rights reserved.
 * @license GNU General Public License v2.0 (or any later version)
 * @package expqueue
 */

/** Thrown by expQueueContext::throwIfCancelled() when the job was cancelled while it ran; the job ends cancelled. */
class expQueueCancelledException extends expQueueException
{
}
