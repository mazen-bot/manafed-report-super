/**
 * نظام التنبيهات المخصصة
 * يستبدل alert(), confirm(), prompt() برسائل جذابة متطابقة مع تصميم الموقع
 */

// إنشاء HTML للنماذج المخصصة
function initCustomAlerts() {
    const alertsContainer = document.createElement('div');
    alertsContainer.id = 'customAlertsContainer';
    alertsContainer.innerHTML = `
        <!-- Modal Container -->
        <div id="customAlertModal" class="custom-modal" style="display: none;">
            <div class="custom-modal-overlay" id="customAlertOverlay"></div>
            <div class="custom-modal-content">
                <div class="custom-modal-header">
                    <div id="customAlertIcon" class="custom-modal-icon">ℹ️</div>
                    <h2 id="customAlertTitle">تنبيه</h2>
                    <button class="custom-modal-close" id="customAlertClose">✕</button>
                </div>
                <div class="custom-modal-body">
                    <p id="customAlertMessage"></p>
                </div>
                <div class="custom-modal-footer">
                    <button id="customAlertButton" class="custom-btn custom-btn-primary">
                        موافق
                    </button>
                </div>
            </div>
        </div>

        <!-- Confirm Modal -->
        <div id="customConfirmModal" class="custom-modal" style="display: none;">
            <div class="custom-modal-overlay" id="customConfirmOverlay"></div>
            <div class="custom-modal-content">
                <div class="custom-modal-header">
                    <div id="customConfirmIcon" class="custom-modal-icon">❓</div>
                    <h2 id="customConfirmTitle">تأكيد</h2>
                    <button class="custom-modal-close" id="customConfirmClose">✕</button>
                </div>
                <div class="custom-modal-body">
                    <p id="customConfirmMessage"></p>
                </div>
                <div class="custom-modal-footer">
                    <button id="customConfirmCancel" class="custom-btn custom-btn-secondary">
                        إلغاء
                    </button>
                    <button id="customConfirmOk" class="custom-btn custom-btn-primary">
                        نعم، متأكد
                    </button>
                </div>
            </div>
        </div>

        <!-- Prompt Modal -->
        <div id="customPromptModal" class="custom-modal" style="display: none;">
            <div class="custom-modal-overlay" id="customPromptOverlay"></div>
            <div class="custom-modal-content">
                <div class="custom-modal-header">
                    <div id="customPromptIcon" class="custom-modal-icon">✏️</div>
                    <h2 id="customPromptTitle">إدخال</h2>
                    <button class="custom-modal-close" id="customPromptClose">✕</button>
                </div>
                <div class="custom-modal-body">
                    <p id="customPromptMessage"></p>
                    <input type="text" id="customPromptInput" class="custom-modal-input" placeholder="أدخل النص هنا">
                </div>
                <div class="custom-modal-footer">
                    <button id="customPromptCancel" class="custom-btn custom-btn-secondary">
                        إلغاء
                    </button>
                    <button id="customPromptOk" class="custom-btn custom-btn-primary">
                        تم
                    </button>
                </div>
            </div>
        </div>

        <!-- Success Toast -->
        <div id="customSuccessToast" class="custom-toast custom-toast-success" style="display: none;">
            <div class="custom-toast-icon">✅</div>
            <div class="custom-toast-content">
                <strong id="customSuccessTitle">نجح</strong>
                <p id="customSuccessMessage"></p>
            </div>
        </div>

        <!-- Error Toast -->
        <div id="customErrorToast" class="custom-toast custom-toast-error" style="display: none;">
            <div class="custom-toast-icon">❌</div>
            <div class="custom-toast-content">
                <strong id="customErrorTitle">خطأ</strong>
                <p id="customErrorMessage"></p>
            </div>
        </div>

        <!-- Warning Toast -->
        <div id="customWarningToast" class="custom-toast custom-toast-warning" style="display: none;">
            <div class="custom-toast-icon">⚠️</div>
            <div class="custom-toast-content">
                <strong id="customWarningTitle">تحذير</strong>
                <p id="customWarningMessage"></p>
            </div>
        </div>

        <!-- Info Toast -->
        <div id="customInfoToast" class="custom-toast custom-toast-info" style="display: none;">
            <div class="custom-toast-icon">ℹ️</div>
            <div class="custom-toast-content">
                <strong id="customInfoTitle">معلومة</strong>
                <p id="customInfoMessage"></p>
            </div>
        </div>
    `;

    document.body.appendChild(alertsContainer);

    // إضافة CSS
    addCustomAlertStyles();

    // ربط الأحداث
    setupCustomAlertListeners();
}

// إضافة أنماط CSS للنماذج المخصصة
function addCustomAlertStyles() {
    const styleElement = document.createElement('style');
    styleElement.id = 'customAlertsStyles';
    styleElement.textContent = `
        :root {
            --custom-primary: #6b2d87;
            --custom-primary-dark: #5a1f6f;
            --custom-primary-light: #8b3dab;
            --custom-success: #4caf50;
            --custom-error: #f44336;
            --custom-warning: #ff9800;
            --custom-info: #2196f3;
            --custom-secondary: #757575;
            --custom-border-radius: 16px;
            --custom-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            --custom-shadow-lg: 0 20px 50px rgba(0, 0, 0, 0.3);
        }

        /* Modal Styles */
        .custom-modal {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 10000;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: customModalFadeIn 0.3s ease-out;
        }

        .custom-modal-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(4px);
        }

        .custom-modal-content {
            position: relative;
            background: white;
            border-radius: var(--custom-border-radius);
            box-shadow: var(--custom-shadow-lg);
            width: 90%;
            max-width: 450px;
            overflow: hidden;
            animation: customModalSlideUp 0.3s ease-out;
            direction: rtl;
            text-align: right;
        }

        .custom-modal-header {
            background: linear-gradient(135deg, var(--custom-primary) 0%, var(--custom-primary-dark) 100%);
            color: white;
            padding: 24px 20px;
            position: relative;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .custom-modal-icon {
            font-size: 32px;
            flex-shrink: 0;
        }

        .custom-modal-header h2 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            flex: 1;
        }

        .custom-modal-close {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            font-size: 20px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            flex-shrink: 0;
        }

        .custom-modal-close:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: rotate(90deg);
        }

        .custom-modal-body {
            padding: 24px 20px;
            max-height: 60vh;
            overflow-y: auto;
        }

        .custom-modal-body p {
            margin: 0 0 12px 0;
            font-size: 15px;
            color: #333;
            line-height: 1.6;
        }

        .custom-modal-input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 15px;
            font-family: 'Segoe UI', 'Cairo', sans-serif;
            transition: all 0.3s;
            box-sizing: border-box;
            margin-top: 12px;
        }

        .custom-modal-input:focus {
            outline: none;
            border-color: var(--custom-primary);
            background-color: #f8f4ff;
            box-shadow: 0 0 0 3px rgba(107, 45, 135, 0.1);
        }

        .custom-modal-footer {
            background: #f8f9fa;
            padding: 16px 20px;
            display: flex;
            gap: 12px;
            justify-content: flex-start;
        }

        .custom-modal-footer button {
            flex: 1;
        }

        /* Button Styles */
        .custom-btn {
            padding: 11px 20px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            font-family: 'Segoe UI', 'Cairo', sans-serif;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            min-height: 40px;
        }

        .custom-btn-primary {
            background: linear-gradient(135deg, var(--custom-primary) 0%, var(--custom-primary-dark) 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(107, 45, 135, 0.3);
        }

        .custom-btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(107, 45, 135, 0.4);
        }

        .custom-btn-primary:active {
            transform: translateY(0);
        }

        .custom-btn-secondary {
            background: #e0e0e0;
            color: #333;
        }

        .custom-btn-secondary:hover {
            background: #d0d0d0;
            transform: translateY(-2px);
        }

        .custom-btn-secondary:active {
            transform: translateY(0);
        }

        .custom-btn-success {
            background: var(--custom-success);
            color: white;
            box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
        }

        .custom-btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(76, 175, 80, 0.4);
        }

        .custom-btn-error {
            background: var(--custom-error);
            color: white;
            box-shadow: 0 4px 12px rgba(244, 67, 54, 0.3);
        }

        .custom-btn-error:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(244, 67, 54, 0.4);
        }

        /* Toast Styles */
        .custom-toast {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: white;
            border-radius: var(--custom-border-radius);
            box-shadow: var(--custom-shadow);
            padding: 16px 20px;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            max-width: 400px;
            z-index: 9999;
            animation: customToastSlideIn 0.4s ease-out;
            direction: rtl;
            text-align: right;
        }

        .custom-toast-icon {
            font-size: 24px;
            flex-shrink: 0;
            margin-top: 4px;
        }

        .custom-toast-content {
            flex: 1;
        }

        .custom-toast-content strong {
            display: block;
            font-size: 14px;
            margin-bottom: 4px;
            font-weight: 700;
        }

        .custom-toast-content p {
            margin: 0;
            font-size: 13px;
            line-height: 1.5;
            opacity: 0.85;
        }

        .custom-toast-success {
            background: linear-gradient(135deg, rgba(76, 175, 80, 0.95) 0%, rgba(56, 142, 60, 0.95) 100%);
            color: white;
            border-left: 4px solid var(--custom-success);
        }

        .custom-toast-error {
            background: linear-gradient(135deg, rgba(244, 67, 54, 0.95) 0%, rgba(211, 47, 47, 0.95) 100%);
            color: white;
            border-left: 4px solid var(--custom-error);
        }

        .custom-toast-warning {
            background: linear-gradient(135deg, rgba(255, 152, 0, 0.95) 0%, rgba(230, 124, 0, 0.95) 100%);
            color: white;
            border-left: 4px solid var(--custom-warning);
        }

        .custom-toast-info {
            background: linear-gradient(135deg, rgba(33, 150, 243, 0.95) 0%, rgba(25, 118, 210, 0.95) 100%);
            color: white;
            border-left: 4px solid var(--custom-info);
        }

        /* Animations */
        @keyframes customModalFadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }

        @keyframes customModalSlideUp {
            from {
                transform: translateY(50px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        @keyframes customToastSlideIn {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        @keyframes customToastSlideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(400px);
                opacity: 0;
            }
        }

        /* Responsive */
        @media (max-width: 480px) {
            .custom-modal-content {
                width: 95%;
                max-width: 100%;
                margin: 10px;
            }

            .custom-toast {
                width: 90%;
                right: 5%;
                left: auto;
                bottom: 10px;
            }

            .custom-modal-header {
                flex-wrap: wrap;
            }

            .custom-modal-footer {
                flex-direction: column;
            }

            .custom-modal-footer button {
                width: 100%;
            }
        }
    `;

    document.head.appendChild(styleElement);
}

// ربط أحداث النماذج
function setupCustomAlertListeners() {
    // Alert Modal
    const alertOverlay = document.getElementById('customAlertOverlay');
    const alertClose = document.getElementById('customAlertClose');
    const alertButton = document.getElementById('customAlertButton');

    if (alertOverlay) alertOverlay.addEventListener('click', hideCustomAlert);
    if (alertClose) alertClose.addEventListener('click', hideCustomAlert);
    if (alertButton) alertButton.addEventListener('click', hideCustomAlert);

    // Confirm Modal
    const confirmOverlay = document.getElementById('customConfirmOverlay');
    const confirmClose = document.getElementById('customConfirmClose');
    const confirmCancel = document.getElementById('customConfirmCancel');
    const confirmOk = document.getElementById('customConfirmOk');

    if (confirmOverlay) confirmOverlay.addEventListener('click', () => confirmCurrentAction(false));
    if (confirmClose) confirmClose.addEventListener('click', () => confirmCurrentAction(false));
    if (confirmCancel) confirmCancel.addEventListener('click', () => confirmCurrentAction(false));
    if (confirmOk) confirmOk.addEventListener('click', () => confirmCurrentAction(true));

    // Prompt Modal
    const promptOverlay = document.getElementById('customPromptOverlay');
    const promptClose = document.getElementById('customPromptClose');
    const promptCancel = document.getElementById('customPromptCancel');
    const promptOk = document.getElementById('customPromptOk');
    const promptInput = document.getElementById('customPromptInput');

    if (promptOverlay) promptOverlay.addEventListener('click', () => submitPromptValue(null));
    if (promptClose) promptClose.addEventListener('click', () => submitPromptValue(null));
    if (promptCancel) promptCancel.addEventListener('click', () => submitPromptValue(null));
    if (promptOk) promptOk.addEventListener('click', () => submitPromptValue(promptInput.value));

    // Allow Enter key to submit prompt
    if (promptInput) {
        promptInput.addEventListener('keypress', (event) => {
            if (event.key === 'Enter') submitPromptValue(promptInput.value);
        });
    }
}

// متغيرات للتعامل مع الإجابات
let customAlertResolve = null;
let customConfirmResolve = null;
let customPromptResolve = null;

// دوال عرض النماذج
function showCustomAlert(message, title = 'تنبيه', type = 'info') {
    const modal = document.getElementById('customAlertModal');
    const messageEl = document.getElementById('customAlertMessage');
    const titleEl = document.getElementById('customAlertTitle');
    const iconEl = document.getElementById('customAlertIcon');

    const icons = {
        info: 'ℹ️',
        success: '✅',
        error: '❌',
        warning: '⚠️'
    };

    if (messageEl) messageEl.textContent = message;
    if (titleEl) titleEl.textContent = title;
    if (iconEl) iconEl.textContent = icons[type] || icons.info;

    if (modal) {
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    return new Promise(resolve => {
        customAlertResolve = resolve;
    });
}

function hideCustomAlert() {
    const modal = document.getElementById('customAlertModal');
    if (modal) {
        modal.style.display = 'none';
        document.body.style.overflow = '';
    }
    if (customAlertResolve) {
        customAlertResolve();
        customAlertResolve = null;
    }
}

function showCustomConfirm(message, title = 'تأكيد') {
    const modal = document.getElementById('customConfirmModal');
    const messageEl = document.getElementById('customConfirmMessage');
    const titleEl = document.getElementById('customConfirmTitle');

    if (messageEl) messageEl.textContent = message;
    if (titleEl) titleEl.textContent = title;

    if (modal) {
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    return new Promise(resolve => {
        customConfirmResolve = resolve;
    });
}

function confirmCurrentAction(result) {
    const modal = document.getElementById('customConfirmModal');
    if (modal) {
        modal.style.display = 'none';
        document.body.style.overflow = '';
    }
    if (customConfirmResolve) {
        customConfirmResolve(result);
        customConfirmResolve = null;
    }
}

function showCustomPrompt(message, title = 'إدخال', defaultValue = '') {
    const modal = document.getElementById('customPromptModal');
    const messageEl = document.getElementById('customPromptMessage');
    const titleEl = document.getElementById('customPromptTitle');
    const inputEl = document.getElementById('customPromptInput');

    if (messageEl) messageEl.textContent = message;
    if (titleEl) titleEl.textContent = title;
    if (inputEl) {
        inputEl.value = defaultValue;
        inputEl.focus();
        inputEl.select();
    }

    if (modal) {
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    return new Promise(resolve => {
        customPromptResolve = resolve;
    });
}

function submitPromptValue(value) {
    const modal = document.getElementById('customPromptModal');
    if (modal) {
        modal.style.display = 'none';
        document.body.style.overflow = '';
    }
    if (customPromptResolve) {
        customPromptResolve(value);
        customPromptResolve = null;
    }
}

// دوال عرض التنبيهات (Toasts)
function showCustomSuccess(message, title = 'نجح') {
    const toast = document.getElementById('customSuccessToast');
    const titleEl = document.getElementById('customSuccessTitle');
    const messageEl = document.getElementById('customSuccessMessage');

    if (titleEl) titleEl.textContent = title;
    if (messageEl) messageEl.textContent = message;

    if (toast) {
        toast.style.display = 'flex';
        toast.style.animation = 'customToastSlideIn 0.4s ease-out';

        setTimeout(() => {
            if (toast.style.display !== 'none') {
                toast.style.animation = 'customToastSlideOut 0.4s ease-in';
                setTimeout(() => {
                    toast.style.display = 'none';
                }, 400);
            }
        }, 4000);
    }
}

function showCustomError(message, title = 'خطأ') {
    const toast = document.getElementById('customErrorToast');
    const titleEl = document.getElementById('customErrorTitle');
    const messageEl = document.getElementById('customErrorMessage');

    if (titleEl) titleEl.textContent = title;
    if (messageEl) messageEl.textContent = message;

    if (toast) {
        toast.style.display = 'flex';
        toast.style.animation = 'customToastSlideIn 0.4s ease-out';

        setTimeout(() => {
            if (toast.style.display !== 'none') {
                toast.style.animation = 'customToastSlideOut 0.4s ease-in';
                setTimeout(() => {
                    toast.style.display = 'none';
                }, 400);
            }
        }, 4500);
    }
}

function showCustomWarning(message, title = 'تحذير') {
    const toast = document.getElementById('customWarningToast');
    const titleEl = document.getElementById('customWarningTitle');
    const messageEl = document.getElementById('customWarningMessage');

    if (titleEl) titleEl.textContent = title;
    if (messageEl) messageEl.textContent = message;

    if (toast) {
        toast.style.display = 'flex';
        toast.style.animation = 'customToastSlideIn 0.4s ease-out';

        setTimeout(() => {
            if (toast.style.display !== 'none') {
                toast.style.animation = 'customToastSlideOut 0.4s ease-in';
                setTimeout(() => {
                    toast.style.display = 'none';
                }, 400);
            }
        }, 4000);
    }
}

function showCustomInfo(message, title = 'معلومة') {
    const toast = document.getElementById('customInfoToast');
    const titleEl = document.getElementById('customInfoTitle');
    const messageEl = document.getElementById('customInfoMessage');

    if (titleEl) titleEl.textContent = title;
    if (messageEl) messageEl.textContent = message;

    if (toast) {
        toast.style.display = 'flex';
        toast.style.animation = 'customToastSlideIn 0.4s ease-out';

        setTimeout(() => {
            if (toast.style.display !== 'none') {
                toast.style.animation = 'customToastSlideOut 0.4s ease-in';
                setTimeout(() => {
                    toast.style.display = 'none';
                }, 400);
            }
        }, 3500);
    }
}

// دالة لإظهار نموذج تأكيد مع ملخص البيانات المرتبة
function showSummaryConfirm(title, items, confirmText = 'تأكيد', cancelText = 'إلغاء') {
    const modal = document.getElementById('customConfirmModal');
    const titleEl = document.getElementById('customConfirmTitle');
    const messageEl = document.getElementById('customConfirmMessage');
    const confirmBtn = document.getElementById('customConfirmOk');
    const cancelBtn = document.getElementById('customConfirmCancel');

    if (titleEl) titleEl.textContent = title;

    // بناء HTML للملخص المرتب
    let summaryHTML = `
        <div style="
            background: #f8f9fa;
            padding: 16px;
            border-radius: 12px;
            max-height: 60vh;
            overflow-y: auto;
            direction: rtl;
        ">
    `;

    // تجميع العناصر حسب الفئات
    const categories = {
        'بيانات عامة': [],
        'المبيعات': [],
        'التمويل': [],
        'العمليات الإضافية': []
    };

    items.forEach(item => {
        if (item.category && categories[item.category]) {
            categories[item.category].push(item);
        }
    });

    // عرض كل فئة مع عناصرها
    Object.entries(categories).forEach(([categoryName, categoryItems]) => {
        if (categoryItems.length > 0) {
            summaryHTML += `
                <div style="margin-bottom: 20px;">
                    <div style="
                        background: linear-gradient(135deg, #6b2d87 0%, #5a1f6f 100%);
                        color: white;
                        padding: 12px 16px;
                        border-radius: 8px;
                        font-weight: 700;
                        margin-bottom: 12px;
                        font-size: 14px;
                    ">
                        ${categoryName}
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 10px;">
            `;

            categoryItems.forEach(item => {
                const bgColor = item.highlight ? '#fff3e0' : '#ffffff';
                const borderColor = item.highlight ? '#ff9800' : '#e0e0e0';
                const textColor = item.highlight ? '#ff6f00' : '#333';
                const fontWeight = item.highlight ? '700' : '600';

                summaryHTML += `
                    <div style="
                        background: ${bgColor};
                        border: 2px solid ${borderColor};
                        border-radius: 8px;
                        padding: 12px 14px;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        gap: 12px;
                    ">
                        <span style="
                            color: #666;
                            font-size: 13px;
                            font-weight: 600;
                            flex: 1;
                        ">${item.label}</span>
                        <span style="
                            color: ${textColor};
                            font-weight: ${fontWeight};
                            font-size: 14px;
                            min-width: 80px;
                            text-align: left;
                        ">${item.value}</span>
                    </div>
                `;
            });

            summaryHTML += `
                    </div>
                </div>
            `;
        }
    });

    summaryHTML += `
        </div>
    `;

    if (messageEl) {
        messageEl.innerHTML = summaryHTML;
    }

    if (modal) {
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    // تحديث نصوص الأزرار
    if (confirmBtn) confirmBtn.textContent = confirmText;
    if (cancelBtn) cancelBtn.textContent = cancelText;

    return new Promise(resolve => {
        // متغيرات لتتبع حالة المعالج
        let isResolved = false;
        
        const handleConfirm = (e) => {
            if (isResolved) return; // منع التنفيذ المتكرر
            isResolved = true;
            e.preventDefault();
            e.stopPropagation();
            cleanup();
            resolve(true);
        };

        const handleCancel = (e) => {
            if (isResolved) return; // منع التنفيذ المتكرر
            isResolved = true;
            e.preventDefault();
            e.stopPropagation();
            cleanup();
            resolve(false);
        };

        const cleanup = () => {
            // التأكد من إزالة المعالجات
            if (confirmBtn) {
                confirmBtn.removeEventListener('click', handleConfirm);
            }
            if (cancelBtn) {
                cancelBtn.removeEventListener('click', handleCancel);
            }
            if (modal) {
                modal.style.display = 'none';
            }
            document.body.style.overflow = '';
        };

        // إضافة المعالجات
        if (confirmBtn) {
            confirmBtn.addEventListener('click', handleConfirm);
        }
        if (cancelBtn) {
            cancelBtn.addEventListener('click', handleCancel);
        }
    });
}

// تهيئة النظام عند تحميل الصفحة
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initCustomAlerts);
} else {
    initCustomAlerts();
}

// Export functions to window for global access / تصدير الدوال للـ window للوصول العام
window.showCustomAlert = showCustomAlert;
window.showCustomConfirm = showCustomConfirm;
window.showCustomPrompt = showCustomPrompt;
window.showCustomSuccess = showCustomSuccess;
window.showCustomError = showCustomError;
window.showCustomWarning = showCustomWarning;
window.showCustomInfo = showCustomInfo;
window.showSummaryConfirm = showSummaryConfirm;
