-- ========================================
-- إعداد Supabase Storage لرفع صور المبيعات
-- ========================================

-- الخطوة 1: إنشاء bucket باسم sales-attachments
-- (يتم من واجهة Supabase → Storage → New Bucket)
-- ✅ ضع علامة على "Public bucket" لجعل الصور قابلة للعرض

-- الخطوة 2: تفعيل سياسات RLS للسماح برفع وقراءة الصور
-- نفّذ هذه الأوامر في SQL Editor:

-- السماح للجميع برفع الصور
CREATE POLICY "Allow public uploads to sales-attachments"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'sales-attachments');

-- السماح للجميع بقراءة الصور
CREATE POLICY "Allow public reads from sales-attachments"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'sales-attachments');

-- السماح للجميع بتحديث الصور (اختياري)
CREATE POLICY "Allow public updates to sales-attachments"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'sales-attachments');

-- السماح للجميع بحذف الصور (اختياري - للإدارة فقط)
CREATE POLICY "Allow public deletes from sales-attachments"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'sales-attachments');

-- ========================================
-- التحقق من السياسات
-- ========================================

-- عرض جميع السياسات على storage.objects
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage';

-- ========================================
-- اختبار رفع ملف (من Console في المتصفح)
-- ========================================

/*
// افتح Console (F12) على صفحة index.html وجرّب:

const testFile = new File(['test content'], 'test.txt', { type: 'text/plain' });

const { data, error } = await supabase.storage
    .from('sales-attachments')
    .upload('test-folder/test.txt', testFile);

console.log('Upload result:', { data, error });

// الحصول على الرابط العام
const { data: urlData } = supabase.storage
    .from('sales-attachments')
    .getPublicUrl('test-folder/test.txt');

console.log('Public URL:', urlData.publicUrl);
*/

-- ========================================
-- ملاحظات هامة
-- ========================================

-- ✅ تأكد من إنشاء bucket باسم: sales-attachments
-- ✅ تأكد من تفعيل "Public bucket"
-- ✅ الصور سيتم رفعها إلى مسار: sales-images/{timestamp}_{random}.{ext}
-- ✅ الرابط المحفوظ في قاعدة البيانات هو رابط عام كامل
-- ✅ الحد الأقصى لحجم الصورة: 5MB (يمكن تعديله من الكود)
