/**
 * Override global functions to use custom alerts
 * استبدال الدوال العامة لاستخدام التنبيهات المخصصة
 */

// Store original functions for fallback
const originalAlert = window.alert;
const originalConfirm = window.confirm;
const originalPrompt = window.prompt;

// Global state for promises
let pendingAlertPromise = null;
let pendingConfirmPromise = null;
let pendingPromptPromise = null;

// Override window.alert() function
window.alert = function(message) {
    // Return a promise that resolves when the alert is dismissed
    return showCustomAlert(message, 'تنبيه', 'info');
};

// Override window.confirm() function
window.confirm = function(message) {
    // This is trickier - we need to handle synchronous usage
    // Create a custom element that blocks execution
    const result = promptSyncConfirm(message);
    return result;
};

// Override window.prompt() function
window.prompt = function(message, defaultValue = '') {
    const result = promptSyncPrompt(message, defaultValue);
    return result;
};

// Synchronous confirm handler using simple modal
function promptSyncConfirm(message) {
    let confirmResult = null;
    let finished = false;

    const modal = document.getElementById('customConfirmModal');
    const messageEl = document.getElementById('customConfirmMessage');
    const titleEl = document.getElementById('customConfirmTitle');
    const confirmBtn = document.getElementById('customConfirmOk');
    const cancelBtn = document.getElementById('customConfirmCancel');

    if (messageEl) messageEl.textContent = message;
    if (titleEl) titleEl.textContent = 'تأكيد';

    if (modal) {
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    // Wait for user response (blocking approach using event listeners)
    return new Promise(resolve => {
        const handleConfirm = () => {
            cleanup();
            resolve(true);
        };

        const handleCancel = () => {
            cleanup();
            resolve(false);
        };

        const cleanup = () => {
            if (confirmBtn) confirmBtn.removeEventListener('click', handleConfirm);
            if (cancelBtn) cancelBtn.removeEventListener('click', handleCancel);
            if (modal) modal.style.display = 'none';
            document.body.style.overflow = '';
        };

        if (confirmBtn) confirmBtn.addEventListener('click', handleConfirm);
        if (cancelBtn) cancelBtn.addEventListener('click', handleCancel);
    });
}

// Synchronous prompt handler
function promptSyncPrompt(message, defaultValue = '') {
    const modal = document.getElementById('customPromptModal');
    const messageEl = document.getElementById('customPromptMessage');
    const titleEl = document.getElementById('customPromptTitle');
    const inputEl = document.getElementById('customPromptInput');
    const promptBtn = document.getElementById('customPromptOk');
    const cancelBtn = document.getElementById('customPromptCancel');

    if (messageEl) messageEl.textContent = message;
    if (titleEl) titleEl.textContent = 'إدخال';
    if (inputEl) {
        inputEl.value = defaultValue;
        // Focus and select in a timeout to ensure it happens after modal is shown
        setTimeout(() => {
            inputEl.focus();
            inputEl.select();
        }, 100);
    }

    if (modal) {
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    return new Promise(resolve => {
        const handleConfirm = () => {
            const value = inputEl ? inputEl.value : null;
            cleanup();
            resolve(value);
        };

        const handleCancel = () => {
            cleanup();
            resolve(null);
        };

        const handleKeyPress = (event) => {
            if (event.key === 'Enter') {
                handleConfirm();
            }
        };

        const cleanup = () => {
            if (promptBtn) promptBtn.removeEventListener('click', handleConfirm);
            if (cancelBtn) cancelBtn.removeEventListener('click', handleCancel);
            if (inputEl) inputEl.removeEventListener('keypress', handleKeyPress);
            if (modal) modal.style.display = 'none';
            document.body.style.overflow = '';
        };

        if (promptBtn) promptBtn.addEventListener('click', handleConfirm);
        if (cancelBtn) cancelBtn.addEventListener('click', handleCancel);
        if (inputEl) inputEl.addEventListener('keypress', handleKeyPress);
    });
}

// Log override initialization
console.log('[Custom Alerts] تم تفعيل نظام التنبيهات المخصصة');
