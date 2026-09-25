# Era pra Ontem

Aplicativo pessoal de organização da rotina docente.

## Publicação no GitHub Pages

1. Crie um repositório no GitHub, por exemplo:
   `era-pra-ontem`

2. Envie para a raiz do repositório:
   - `index.html`
   - `.nojekyll`

3. No GitHub, abra:
   **Settings → Pages**

4. Em **Build and deployment**:
   - Source: **Deploy from a branch**
   - Branch: **main**
   - Folder: **/(root)**

5. Clique em **Save**.

Depois de alguns instantes, o GitHub exibirá o endereço público do site.

## Observação importante

Os dados do aplicativo são salvos no `localStorage` do navegador.
Isso significa que publicar uma nova versão do `index.html` não apaga
os dados já salvos, desde que o endereço do site permaneça o mesmo.
