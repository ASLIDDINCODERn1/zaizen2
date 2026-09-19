# Zaizen — Supabase login sozlash

Loyiha: `https://vazzsnxyqbumqstjgsln.supabase.co`

Kod allaqachon ulangan. Login **real** ishlashi uchun dashboardda 4 ta qadam qilinadi.

## 1. SQL ni ishga tushirish

Supabase Dashboard → **SQL Editor** → `supabase/setup.sql` faylidagi skriptni Run qiling.

Bu `profiles` jadvali, RLS, `avatars` bucket va `delete_own_account` funksiyasini yaratadi.

## 2. Email login (hozir yoqilgan)

Authentication → Providers → **Email**

Tez test uchun:
- **Confirm email** ni **OFF** qiling.
  Aks holda signup qilgandan keyin email tasdiqlanmaguncha kirib bo\u2018lmaydi.
- SMTP sozlanmagan bo\u2018lsa tasdiqlash xati kelmaydi.

## 3. Google (hozir dashboardda O\u2018CHIQ)

Hozir loyihada `google: false`. Shu sababli Google tugmasi xato qaytaradi.

Authentication → Providers → **Google** → Enable

1. Google Cloud Console da OAuth 2.0 Client (Web) yarating.
2. Authorized redirect URI:
   `https://vazzsnxyqbumqstjgsln.supabase.co/auth/v1/callback`
3. Client ID va Client Secret ni Supabase Google provideriga qo\u2018ying.

Authentication → URL Configuration:
- Site URL: `io.zaizen.app://login-callback/`
- Redirect URLs ga qo\u2018shing:
  - `io.zaizen.app://login-callback/`
  - `io.zaizen.app://login-callback`

Facebook ham xuddi shu tartibda (hozir o\u2018chiq).

## 4. Flutter

```bash
flutter pub get
flutter run
```

Yangi foydalanuvchi login qilmaguncha Home ga kira olmaydi.
Session saqlanadi — ilovani yopib ochganda qayta kiritmaydi.
Profil: ism va rasm tahrirlash, logout, akkauntni o\u2018chirish.
