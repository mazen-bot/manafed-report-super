// EmailJS Notifications Module

// Initialize EmailJS with your credentials
const EmailJSConfig = {
    serviceID: 'service_skvlwej', // Replace with your EmailJS service ID
    templateIDLeaveRequest: 'template_leave_request',
    templateIDLeaveApproval: 'template_leave_approval',
    templateIDMedicalReminder: 'template_medical_reminder',
    templateIDWarningIssued: 'template_warning_issued',
    publicKey: 'raY5iQKog8iggJUoY' // Replace with your EmailJS public key
};

// Initialize EmailJS when library is ready
function initializeEmailJS() {
    let attempts = 0;
    const maxAttempts = 20;
    
    function tryInit() {
        attempts++;
        
        if (typeof window.emailjs !== 'undefined' && window.emailjs) {
            try {
                emailjs.init(EmailJSConfig.publicKey);
                console.log('✅ EmailJS initialized successfully');
                window.emailjsReady = true;
                window.emailjsInitialized = true;
                return;
            } catch (error) {
                console.error('❌ Error initializing EmailJS:', error);
                window.emailjsReady = false;
            }
        } else {
            if (attempts < maxAttempts) {
                if (attempts === 1) {
                    console.log('⏳ Waiting for EmailJS library to load...');
                }
                setTimeout(tryInit, 200);
            } else {
                console.warn('⚠️ EmailJS library did not load. Email notifications will be disabled.');
                window.emailjsReady = false;
            }
        }
    }
    
    tryInit();
}

function formatSupabaseError(err) {
    if (!err) return 'Unknown error';
    if (typeof err === 'string') return err;
    if (err.message) return err.message;
    try {
        return JSON.stringify(err);
    } catch (stringifyError) {
        return String(err);
    }
}

// Auto-initialize when this script loads
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeEmailJS);
} else {
    initializeEmailJS();
}

// Get manager email and employee info
async function getManagerAndEmployeeEmails(employeeId) {
    const supabase = window.supabaseInstance;
    
    try {
        if (!supabase) {
            console.error('❌ Supabase is not initialized');
            return null;
        }
        if (!employeeId) {
            console.error('❌ Missing employeeId for email lookup');
            return null;
        }
        // Get employee info
        const { data: employee, error: empError } = await supabase
            .from('employees')
            .select('employee_id, name, email, manager_id')
            .eq('employee_id', employeeId)
            .single();

        if (empError) {
            console.error('Error fetching employee:', formatSupabaseError(empError));
            throw empError;
        }

        if (!employee) {
            console.error('Employee not found:', employeeId);
            return null;
        }

        let managerEmail = null;
        let managerName = null;

        // Get manager info if exists
        if (employee.manager_id) {
            const { data: manager, error: mgrError } = await supabase
                .from('employees')
                .select('employee_id, name, email')
                .eq('employee_id', employee.manager_id)
                .single();

            if (!mgrError && manager) {
                managerEmail = manager.email;
                managerName = manager.name;
            } else if (mgrError) {
                console.warn('Could not fetch manager info:', formatSupabaseError(mgrError));
            }
        }

        return {
            employeeEmail: employee.email,
            employeeName: employee.name,
            managerEmail: managerEmail,
            managerName: managerName
        };
    } catch (error) {
        console.error('❌ Error fetching employee/manager emails:', formatSupabaseError(error));
        return null;
    }
}

// Send leave request notification
async function sendLeaveRequestNotification(leaveData) {
    try {
        // Check if EmailJS is available
        if (!window.emailjsReady) {
            if (window.emailjsReady === false) {
                console.warn('⚠️ EmailJS is not available - notification cannot be sent');
                return false;
            }
            // Wait a bit for initialization
            await new Promise(resolve => setTimeout(resolve, 1000));
            if (!window.emailjsReady) {
                console.warn('⚠️ EmailJS initialization timeout');
                return false;
            }
        }

        const emails = await getManagerAndEmployeeEmails(leaveData.employee_id);
        if (!emails) {
            console.warn('⚠️ Could not fetch emails for leave notification');
            return false;
        }

        // التحقق من وجود المدير
        if (!emails.managerEmail) {
            console.warn('⚠️ No manager email found - notification cannot be sent');
            return false;
        }

        // Email parameters - يُرسل للمدير فقط عند رفع الطلب
        const emailParams = {
            employee_name: emails.employeeName,
            leave_type: leaveData.leave_type || leaveData.request_type || 'إجازة',
            from_date: leaveData.from_date,
            to_date: leaveData.to_date,
            days_count: leaveData.days_count,
            reason: leaveData.reason || 'بدون تفاصيل',
            request_date: new Date().toLocaleDateString('ar-EG'),
            to_email: emails.managerEmail,
            to_name: emails.managerName
        };

        // إرسال للمدير فقط
        await emailjs.send(
            EmailJSConfig.serviceID,
            EmailJSConfig.templateIDLeaveRequest,
            emailParams
        );

        console.log('✅ Leave request notification sent to manager');

        return true;
    } catch (error) {
        console.error('❌ Error sending leave request notification:', error);
        return false;
    }
}

// Send leave approval/rejection notification
async function sendLeaveApprovalNotification(leaveData, approvalStatus, approverNotes = '') {
    console.log('📧 Starting approval notification send...');
    console.log('Leave data:', leaveData);
    console.log('Approval status:', approvalStatus);
    console.log('Approver notes:', approverNotes);
    
    try {
        // Check if EmailJS is available
        if (!window.emailjsReady) {
            if (window.emailjsReady === false) {
                console.warn('⚠️ EmailJS is not available - notification cannot be sent');
                return false;
            }
            await new Promise(resolve => setTimeout(resolve, 1000));
            if (!window.emailjsReady) {
                console.warn('⚠️ EmailJS initialization timeout');
                return false;
            }
        }

        console.log('✅ EmailJS is ready');
        console.log('Fetching employee emails for:', leaveData.employee_id);

        const emails = await getManagerAndEmployeeEmails(leaveData.employee_id);
        if (!emails) {
            console.warn('⚠️ Could not fetch emails for approval notification');
            return false;
        }

        console.log('Emails fetched:', emails);

        // التحقق من وجود إيميل الموظف
        if (!emails.employeeEmail) {
            console.warn('⚠️ No employee email found - notification cannot be sent');
            console.warn('Employee email:', emails.employeeEmail);
            return false;
        }

        console.log('✅ Employee email found:', emails.employeeEmail);

        const statusAr = approvalStatus === 'approved' ? 'موافق عليه ✅' : 'مرفوض ❌';
        const statusColor = approvalStatus === 'approved' ? 'green' : 'red';

        console.log('Preparing email parameters...');

        // Email parameters - يُرسل للموظف فقط عند الموافقة/الرفض
        const emailParams = {
            employee_name: emails.employeeName,
            leave_type: leaveData.leave_type || leaveData.request_type || 'إجازة',
            from_date: leaveData.from_date,
            to_date: leaveData.to_date,
            approval_status: statusAr,
            status_color: statusColor,
            approver_notes: approverNotes || 'لا توجد ملاحظات',
            approval_date: new Date().toLocaleDateString('ar-EG'),
            to_email: emails.employeeEmail,
            to_name: emails.employeeName
        };

        console.log('Email parameters:', emailParams);
        console.log('Sending email to:', emails.employeeEmail);

        // إرسال للموظف فقط
        await emailjs.send(
            EmailJSConfig.serviceID,
            EmailJSConfig.templateIDLeaveApproval,
            emailParams
        );

        console.log(`✅ Leave ${approvalStatus} notification sent to employee: ${emails.employeeEmail}`);
        console.log('✅ Email sent successfully!');

        return true;
    } catch (error) {
        console.error('❌ Error sending approval notification:', error);
        return false;
    }
}

// Send medical certificate deadline reminder
async function sendMedicalDeadlineReminder(leaveData, daysLeft) {
    try {
        // Check if EmailJS is available
        if (!window.emailjsReady) {
            if (window.emailjsReady === false) {
                console.warn('⚠️ EmailJS is not available - medical reminder cannot be sent');
                return false;
            }
            await new Promise(resolve => setTimeout(resolve, 1000));
            if (!window.emailjsReady) {
                console.warn('⚠️ EmailJS initialization timeout');
                return false;
            }
        }

        const emails = await getManagerAndEmployeeEmails(leaveData.employee_id);
        if (!emails) {
            console.warn('⚠️ Could not fetch emails for medical reminder');
            return false;
        }

        const urgencyMessage = daysLeft <= 1 ? 
            '⏰ هام جداً: يتبقى يوم واحد فقط!' :
            `⚠️ تنبيه: يتبقى ${daysLeft} أيام`;

        const emailParams = {
            employee_name: emails.employeeName,
            from_date: leaveData.from_date,
            to_date: leaveData.to_date,
            days_left: daysLeft,
            urgency_message: urgencyMessage,
            deadline_date: new Date(new Date(leaveData.created_at).getTime() + 3 * 24 * 60 * 60 * 1000).toLocaleDateString('ar-EG'),
            to_email: emails.employeeEmail,
            to_name: emails.employeeName
        };

        // Send to employee
        await emailjs.send(
            EmailJSConfig.serviceID,
            EmailJSConfig.templateIDMedicalReminder,
            emailParams
        );

        console.log('✅ Medical deadline reminder sent to employee');

        // Send to manager if exists
        if (emails.managerEmail) {
            emailParams.to_email = emails.managerEmail;
            emailParams.to_name = emails.managerName;

            await emailjs.send(
                EmailJSConfig.serviceID,
                EmailJSConfig.templateIDMedicalReminder,
                emailParams
            );

            console.log('✅ Medical deadline reminder sent to manager');
        }

        return true;
    } catch (error) {
        console.error('❌ Error sending medical reminder:', error);
        return false;
    }
}

// Send warning issued notification
async function sendWarningNotification(employeeId, warningData) {
    try {
        // Check if EmailJS is available
        if (!window.emailjsReady) {
            if (window.emailjsReady === false) {
                console.warn('⚠️ EmailJS is not available - warning notification cannot be sent');
                return false;
            }
            await new Promise(resolve => setTimeout(resolve, 1000));
            if (!window.emailjsReady) {
                console.warn('⚠️ EmailJS initialization timeout');
                return false;
            }
        }

        const emails = await getManagerAndEmployeeEmails(employeeId);
        if (!emails) {
            console.warn('⚠️ Could not fetch emails for warning notification');
            return false;
        }

        const emailParams = {
            employee_name: emails.employeeName,
            warning_type: warningData.warning_type || 'تنبيه',
            reason: warningData.reason || 'بدون تفاصيل',
            warning_date: new Date().toLocaleDateString('ar-EG'),
            warning_number: warningData.warning_number || 1,
            action_required: warningData.action_required || 'الالتزام بالحضور والانضباط',
            to_email: emails.employeeEmail,
            to_name: emails.employeeName
        };

        // Send to employee
        await emailjs.send(
            EmailJSConfig.serviceID,
            EmailJSConfig.templateIDWarningIssued,
            emailParams
        );

        console.log('✅ Warning notification sent to employee');

        // Send to manager if exists
        if (emails.managerEmail) {
            emailParams.to_email = emails.managerEmail;
            emailParams.to_name = emails.managerName;

            await emailjs.send(
                EmailJSConfig.serviceID,
                EmailJSConfig.templateIDWarningIssued,
                emailParams
            );

            console.log('✅ Warning notification sent to manager');
        }

        return true;
    } catch (error) {
        console.error('❌ Error sending warning notification:', error);
        return false;
    }
}

// Send custom email
async function sendCustomEmail(recipientEmail, recipientName, templateId, params) {
    try {
        // Check if EmailJS is available
        if (!window.emailjsReady) {
            if (window.emailjsReady === false) {
                console.warn('⚠️ EmailJS is not available - custom email cannot be sent');
                return false;
            }
            await new Promise(resolve => setTimeout(resolve, 1000));
            if (!window.emailjsReady) {
                console.warn('⚠️ EmailJS initialization timeout');
                return false;
            }
        }

        const emailParams = {
            to_email: recipientEmail,
            to_name: recipientName,
            ...params
        };

        await emailjs.send(
            EmailJSConfig.serviceID,
            templateId,
            emailParams
        );

        console.log('✅ Custom email sent successfully');
        return true;
    } catch (error) {
        console.error('❌ Error sending custom email:', error);
        return false;
    }
}

// Auto-initialization handled above in initializeEmailJS()
