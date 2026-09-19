# Zaizen email sozlamalari

Supabase dashboard: Authentication → Email Templates

1. Sender name: `Zaizen`
2. Sender email (Custom SMTP bo'lsa): masalan `noreply@zaizen.app`
3. Confirm signup: `supabase/email/confirm.html` ni to'liq joylashtiring
4. Reset password: `supabase/email/reset.html` ni to'liq joylashtiring
5. Subject (confirm): `Zaizen — emailni tasdiqlang`
6. Subject (reset): `Zaizen — parolni tiklash`

Logo hozir GitHub raw URL orqali chiqadi:
`https://raw.githubusercontent.com/ASLIDDINCODERn1/zaizen1/main/assets/logo.png`

Ixtiyoriy: `zaizen/brand/logo.png` ga yuklab, HTML ichidagi `src` ni
`https://vazzsnxyqbumqstjgsln.supabase.co/storage/v1/object/public/zaizen/brand/logo.png`
ga almashtirish mumkin.

SQL: `supabase/setup.sql` ni SQL Editor da qayta ishga tushiring —
`delete_own_account` storage + profiles + auth.users ni o'chiradi.
