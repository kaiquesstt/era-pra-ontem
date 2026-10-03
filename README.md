# Era pra Ontem

Aplicativo pessoal de organização da rotina docente.

## Publicação no GitHub Pages

1. Envie para a raiz do repositório o arquivo `index.html`.
2. No GitHub, abra **Settings → Pages**.
3. Em **Build and deployment**, escolha **Deploy from a branch**, branch **main**, pasta **/(root)** e clique em **Save**.

Depois de alguns instantes, o GitHub exibirá o endereço público do site.

## Dados

Os dados ficam no `localStorage` do navegador e, opcionalmente, na nuvem (Supabase, com RLS).
Nenhum dado pessoal de alunos fica no código publicado.
Publicar uma nova versão do `index.html` não apaga os dados salvos, desde que o endereço do site continue o mesmo.
