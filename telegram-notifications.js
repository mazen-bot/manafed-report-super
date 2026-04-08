// ================================================
// Telegram Bot Notifications Module
// نظام إشعارات تليجرام - مجاني 100%
// ================================================

// Telegram Bot Configuration
const TelegramConfig = {
    botToken: '8655814759:AAEg_pdZWc7j-VCarZoX0CslvyXtNs8FiPE', // ضع Bot Token هنا من @BotFather
    apiUrl: 'https://api.telegram.org/bot'
};

// ================================================
// دوال مساعدة
// ================================================

/**
 * تأمين النص من أحرف HTML الخاصة
 */
function escapeHtml(text) {
    return String(text || '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
}

/**
 * إرسال رسالة تليجرام
 * @param {string} chatId - معرف المحادثة
 * @param {string} message - نص الرسالة (يدعم HTML)
 * @returns {Promise<boolean>} - نجح أو فشل
 */
async function sendTelegramMessage(chatId, message) {
    if (!chatId) {
        console.warn('⚠️ No chat ID provided');
        return false;
    }

    if (!TelegramConfig.botToken || TelegramConfig.botToken === 'YOUR_BOT_TOKEN_HERE') {
        console.warn('⚠️ Telegram Bot Token not configured');
        return false;
    }

    try {
        const url = `${TelegramConfig.apiUrl}${TelegramConfig.botToken}/sendMessage`;
        
        console.log('📤 Sending Telegram message to:', chatId);
        
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                chat_id: chatId,
                text: message,
                parse_mode: 'HTML', // يدعم تنسيق HTML
                disable_web_page_preview: true
            })
        });

        const result = await response.json();
        
        if (result.ok) {
            console.log('✅ Telegram message sent successfully');
            return true;
        } else {
            console.error('❌ Telegram API error:', result.description);
            return false;
        }
    } catch (error) {
        console.error('❌ Error sending Telegram message:', error);
        return false;
    }
}

/**
 * جلب Chat IDs من قاعدة البيانات
 * @param {string} employeeId - الرقم الوظيفي
 * @returns {Promise<object|null>} - بيانات Chat IDs
 */
async function getTelegramChatIds(employeeId) {
    const supabase = window.supabaseInstance;
    
    if (!supabase) {
        console.error('❌ Supabase is not initialized');
        return null;
    }

    if (!employeeId) {
        console.error('❌ Missing employeeId');
        return null;
    }
    
    try {
        // جلب بيانات الموظف
        const { data: employee, error: empError } = await supabase
            .from('employees')
            .select('employee_id, name, telegram_chat_id, manager_id')
            .eq('employee_id', employeeId)
            .single();

        if (empError) {
            console.error('Error fetching employee:', empError);
            return null;
        }

        if (!employee) {
            console.error('Employee not found:', employeeId);
            return null;
        }

        console.log('✅ Employee found:', {
            employee_id: employee.employee_id,
            name: employee.name,
            has_chat_id: !!employee.telegram_chat_id,
            manager_id: employee.manager_id
        });

        let managerChatId = null;
        let managerName = null;
        let managerHasChatId = false;

        // جلب Chat ID للمدير إذا كان موجود
        if (!employee.manager_id) {
            console.warn('⚠️ No manager assigned to employee:', employeeId);
            console.log('💡 Solution: Assign a manager to this employee in admin.html');
        } else {
            const { data: manager, error: mgrError } = await supabase
                .from('employees')
                .select('employee_id, name, telegram_chat_id')
                .eq('employee_id', employee.manager_id)
                .single();

            if (mgrError) {
                console.error('❌ Error fetching manager:', mgrError);
            } else if (manager) {
                managerName = manager.name;
                managerChatId = manager.telegram_chat_id;
                managerHasChatId = !!manager.telegram_chat_id;
                
                console.log('✅ Manager found:', {
                    manager_id: employee.manager_id,
                    manager_name: manager.name,
                    has_chat_id: managerHasChatId
                });

                if (!managerHasChatId) {
                    console.warn('⚠️ Manager has no Telegram Chat ID');
                    console.log('💡 Solution: Add Chat ID for manager (' + employee.manager_id + ') in admin.html');
                    console.log('   1. Open admin.html');
                    console.log('   2. Go to "إدارة الإيميلات والمديرين"');
                    console.log('   3. Search for manager: ' + employee.manager_id);
                    console.log('   4. Click "Chat ID" button');
                    console.log('   5. Enter Chat ID from @userinfobot');
                }
            } else {
                console.error('❌ Manager not found with ID:', employee.manager_id);
            }
        }

        return {
            employeeChatId: employee.telegram_chat_id,
            employeeName: employee.name,
            managerChatId: managerChatId,
            managerName: managerName || 'بدون اسم',
            managerId: employee.manager_id
        };
    } catch (error) {
        console.error('❌ Error fetching Telegram chat IDs:', error);
        return null;
    }
}

// ================================================
// دوال إرسال الإشعارات
// ================================================

/**
 * إشعار طلب إجازة جديد (للمدير)
 * @param {object} leaveData - بيانات الإجازة
 * @returns {Promise<boolean>}
 */
async function sendLeaveRequestTelegram(leaveData) {
    console.log('📧 Sending leave request Telegram notification...');
    console.log('Employee ID:', leaveData.employee_id);
    
    try {
        const chatIds = await getTelegramChatIds(leaveData.employee_id);
        
        if (!chatIds) {
            console.error('❌ Could not fetch chat IDs from database');
            console.error('❌ Leave request Telegram notification could not be sent');
            return false;
        }

        // التحقق من وجود مدير
        if (!chatIds.managerId) {
            console.error('❌ No manager assigned to employee:', leaveData.employee_id);
            console.error('Solution:');
            console.error('  1. Open admin.html');
            console.error('  2. Go to "إدارة الإيميلات والمديرين"');
            console.error('  3. Search for employee:', leaveData.employee_id);
            console.error('  4. Click "مدير" button');
            console.error('  5. Enter manager ID (e.g., 1003)');
            return false;
        }

        // التحقق من Chat ID للمدير
        if (!chatIds.managerChatId) {
            console.error('❌ No manager Telegram Chat ID found');
            console.error('Manager Details:');
            console.error('  - Manager ID:', chatIds.managerId);
            console.error('  - Manager Name:', chatIds.managerName || 'Not specified');
            console.error('Solution:');
            console.error('  1. Open admin.html');
            console.error('  2. Go to "إدارة الإيميلات والمديرين"');
            console.error('  3. Search for manager ID:', chatIds.managerId);
            console.error('  4. Click "Chat ID" button');
            console.error('  5. Open Telegram and search for @userinfobot');
            console.error('  6. Click Start and copy your Chat ID');
            console.error('  7. Paste Chat ID in the prompt');
            return false;
        }

        const leaveTypeAr = {
            'vacation': 'إجازة سنوية',
            'sick': 'إجازة مرضية',
            'permission': 'إذن'
        }[leaveData.request_type] || leaveData.request_type || 'إجازة';

        const message = `
🔔 <b>طلب إجازة جديد</b>

👤 <b>الموظف:</b> ${escapeHtml(chatIds.employeeName)}
📋 <b>النوع:</b> ${escapeHtml(leaveTypeAr)}
📅 <b>من:</b> ${escapeHtml(leaveData.from_date)}
📅 <b>إلى:</b> ${escapeHtml(leaveData.to_date)}
🔢 <b>الأيام:</b> ${escapeHtml(leaveData.days_count)}
📝 <b>السبب:</b> ${escapeHtml(leaveData.reason || 'بدون تفاصيل')}

⏰ <b>تاريخ الطلب:</b> ${new Date().toLocaleDateString('ar-EG')}

⚠️ يرجى مراجعة الطلب من نظام إدارة الموارد البشرية.
        `.trim();

        console.log('📤 Sending Telegram message to manager:', chatIds.managerId);
        const sent = await sendTelegramMessage(chatIds.managerChatId, message);
        
        if (sent) {
            console.log('✅ Leave request Telegram sent to manager:', chatIds.managerName);
        } else {
            console.error('❌ Failed to send Telegram message to manager');
        }
        
        return sent;
    } catch (error) {
        console.error('❌ Error sending leave request Telegram:', error);
        return false;
    }
}

/**
 * إشعار الموافقة/الرفض (للموظف)
 * @param {object} leaveData - بيانات الإجازة
 * @param {string} approvalStatus - 'approved' أو 'rejected'
 * @param {string} approverNotes - ملاحظات الموافق
 * @returns {Promise<boolean>}
 */
async function sendLeaveApprovalTelegram(leaveData, approvalStatus, approverNotes = '') {
    console.log('📧 Sending leave approval Telegram notification...');
    console.log('Employee ID:', leaveData.employee_id);
    console.log('Status:', approvalStatus);
    
    try {
        const chatIds = await getTelegramChatIds(leaveData.employee_id);
        
        if (!chatIds) {
            console.error('❌ Could not fetch chat IDs from database');
            return false;
        }

        if (!chatIds.employeeChatId) {
            console.error('❌ No employee Telegram Chat ID found');
            console.error('Employee Details:');
            console.error('  - Employee ID:', leaveData.employee_id);
            console.error('  - Employee Name:', chatIds.employeeName || 'Not specified');
            console.error('Solution:');
            console.error('  1. Open admin.html');
            console.error('  2. Go to "إدارة الإيميلات والمديرين"');
            console.error('  3. Search for employee ID:', leaveData.employee_id);
            console.error('  4. Click "Chat ID" button');
            console.error('  5. Open Telegram and search for @userinfobot');
            console.error('  6. Click Start and copy your Chat ID');
            console.error('  7. Paste Chat ID in the prompt');
            return false;
        }

        const statusEmoji = approvalStatus === 'approved' ? '✅' : '❌';
        const statusText = approvalStatus === 'approved' ? 'تمت الموافقة' : 'تم الرفض';

        const leaveTypeAr = {
            'vacation': 'إجازة سنوية',
            'sick': 'إجازة مرضية',
            'permission': 'إذن'
        }[leaveData.request_type] || leaveData.request_type || 'إجازة';

        const message = `
${statusEmoji} <b>${escapeHtml(statusText)} على طلب الإجازة</b>

👤 <b>عزيزي:</b> ${escapeHtml(chatIds.employeeName)}

📋 <b>النوع:</b> ${escapeHtml(leaveTypeAr)}
📅 <b>من:</b> ${escapeHtml(leaveData.from_date)}
📅 <b>إلى:</b> ${escapeHtml(leaveData.to_date)}

${statusEmoji} <b>الحالة:</b> ${escapeHtml(statusText)}

📝 <b>ملاحظات:</b> ${escapeHtml(approverNotes || 'لا توجد ملاحظات')}

⏰ <b>تاريخ الرد:</b> ${new Date().toLocaleDateString('ar-EG')}
        `.trim();

        console.log('📤 Sending Telegram message to employee:', leaveData.employee_id);
        const sent = await sendTelegramMessage(chatIds.employeeChatId, message);
        
        if (sent) {
            console.log(`✅ Leave ${approvalStatus} Telegram sent to employee:`, chatIds.employeeName);
        } else {
            console.error('❌ Failed to send Telegram message to employee');
        }
        
        return sent;
    } catch (error) {
        console.error('❌ Error sending approval Telegram:', error);
        return false;
    }
}

/**
 * إشعار تذكير الشهادة الطبية (للموظف)
 * @param {object} leaveData - بيانات الإجازة
 * @param {number} daysLeft - الأيام المتبقية
 * @returns {Promise<boolean>}
 */
async function sendMedicalReminderTelegram(leaveData, daysLeft) {
    console.log('📧 Sending medical reminder Telegram notification...');
    
    try {
        const chatIds = await getTelegramChatIds(leaveData.employee_id);
        
        if (!chatIds || !chatIds.employeeChatId) {
            console.warn('⚠️ No employee Telegram chat ID found');
            return false;
        }

        const urgency = daysLeft <= 1 ? '🚨 <b>عاجل!</b>' : '⚠️';

        const message = `
${urgency} <b>تذكير: الشهادة الطبية مطلوبة</b>

👤 <b>عزيزي:</b> ${escapeHtml(chatIds.employeeName)}

📋 <b>نوع الإجازة:</b> إجازة مرضية
📅 <b>من:</b> ${escapeHtml(leaveData.from_date)}
📅 <b>إلى:</b> ${escapeHtml(leaveData.to_date)}

⏰ <b>المدة المتبقية:</b> ${escapeHtml(daysLeft)} يوم

📎 يرجى رفع الشهادة الطبية قبل انتهاء المهلة.

يمكنك رفعها من نظام إدارة الموارد البشرية.
        `.trim();

        const sent = await sendTelegramMessage(chatIds.employeeChatId, message);
        
        if (sent) {
            console.log('✅ Medical reminder Telegram sent to employee');
        }
        
        return sent;
    } catch (error) {
        console.error('❌ Error sending medical reminder Telegram:', error);
        return false;
    }
}

/**
 * إشعار إنذار جديد (للموظف)
 * @param {string} employeeId - الرقم الوظيفي
 * @param {object} warningData - بيانات الإنذار
 * @returns {Promise<boolean>}
 */
async function sendWarningTelegram(employeeId, warningData) {
    console.log('📧 Sending warning Telegram notification...');
    
    try {
        const chatIds = await getTelegramChatIds(employeeId);
        
        if (!chatIds || !chatIds.employeeChatId) {
            console.warn('⚠️ No employee Telegram chat ID found');
            return false;
        }

        const warningEmoji = {
            'تنبيه': '⚠️',
            'إنذار أول': '⚠️',
            'إنذار ثاني': '🔴',
            'إنذار نهائي': '🚨'
        }[warningData.warning_level] || '⚠️';

        const message = `
${warningEmoji} <b>إشعار: ${escapeHtml(warningData.warning_level)}</b>

👤 <b>عزيزي:</b> ${escapeHtml(chatIds.employeeName)}

📋 <b>نوع الإنذار:</b> ${escapeHtml(warningData.warning_level)}
📝 <b>السبب:</b> ${escapeHtml(warningData.reason)}
👔 <b>صادر من:</b> ${escapeHtml(warningData.issued_by_name)}

⏰ <b>التاريخ:</b> ${new Date().toLocaleDateString('ar-EG')}

⚠️ يرجى مراجعة الإنذار والاطلاع عليه من نظام إدارة الموارد البشرية.
        `.trim();

        const sent = await sendTelegramMessage(chatIds.employeeChatId, message);
        
        if (sent) {
            console.log('✅ Warning Telegram sent to employee');
        }
        
        return sent;
    } catch (error) {
        console.error('❌ Error sending warning Telegram:', error);
        return false;
    }
}

/**
 * إشعار تأكيد استلام الإنذار (للمدير)
 * @param {string} employeeId - الرقم الوظيفي
 * @param {object} warningData - بيانات الإنذار
 * @returns {Promise<boolean>}
 */
async function sendWarningAcknowledgementTelegram(employeeId, warningData) {
    console.log('📧 Sending warning acknowledgement Telegram notification...');

    try {
        const chatIds = await getTelegramChatIds(employeeId);

        if (!chatIds) {
            console.warn('⚠️ Could not fetch chat IDs');
            return false;
        }

        if (!chatIds.managerChatId) {
            console.warn('⚠️ No manager Telegram chat ID found');
            return false;
        }

        const ackDate = warningData.acknowledged_at
            ? new Date(warningData.acknowledged_at).toLocaleDateString('ar-EG')
            : new Date().toLocaleDateString('ar-EG');

        const message = `
✅ <b>تأكيد استلام إنذار</b>

👤 <b>الموظف:</b> ${escapeHtml(chatIds.employeeName)}
📋 <b>نوع الإنذار:</b> ${escapeHtml(warningData.warning_level || 'تنبيه')}
📝 <b>السبب:</b> ${escapeHtml(warningData.reason || 'بدون تفاصيل')}

🕒 <b>تاريخ التأكيد:</b> ${ackDate}

✅ تم تأكيد استلام الإنذار من قبل الموظف.
        `.trim();

        const sent = await sendTelegramMessage(chatIds.managerChatId, message);

        if (sent) {
            console.log('✅ Warning acknowledgement Telegram sent to manager');
        }

        return sent;
    } catch (error) {
        console.error('❌ Error sending warning acknowledgement Telegram:', error);
        return false;
    }
}

// ================================================
// تصدير للاستخدام
// ================================================

// جعل الدوال متاحة globally
window.TelegramConfig = TelegramConfig;
window.sendTelegramMessage = sendTelegramMessage;
window.getTelegramChatIds = getTelegramChatIds;
window.sendLeaveRequestTelegram = sendLeaveRequestTelegram;
window.sendLeaveApprovalTelegram = sendLeaveApprovalTelegram;
window.sendMedicalReminderTelegram = sendMedicalReminderTelegram;
window.sendWarningTelegram = sendWarningTelegram;
window.sendWarningAcknowledgementTelegram = sendWarningAcknowledgementTelegram;

console.log('✅ Telegram notifications module loaded');
console.log('📱 Bot Token configured:', TelegramConfig.botToken !== 'YOUR_BOT_TOKEN_HERE' ? '✅ Yes' : '❌ No - Please configure');
