import type { Locator, Page, Response } from 'playwright';

export type CampoCliente = 'nome' | 'email' | 'cep';

const CAMPOS: Record<string, CampoCliente> = {
  nome: 'nome',
  'e-mail': 'email',
  email: 'email',
  cep: 'cep',
};

export function campoCliente(rotulo: string): CampoCliente {
  const campo = CAMPOS[rotulo.trim().toLowerCase()];
  if (!campo) throw new Error(`Campo desconhecido: ${rotulo}`);
  return campo;
}

export class CheckoutPage {
  constructor(private readonly page: Page) {}

  input(campo: CampoCliente): Locator {
    return this.page.locator(`#campo-${campo}`);
  }

  erro(campo: CampoCliente): Locator {
    return this.page.locator(`#campo-${campo}-erro`);
  }

  async preencher(dados: Partial<Record<CampoCliente, string>>) {
    for (const [campo, valor] of Object.entries(dados)) {
      await this.input(campo as CampoCliente).fill(valor ?? '');
    }
  }

  // Resposta da API no último envio (null se o front bloqueou)
  ultimaResposta: Response | null = null;

  async confirmar() {
    // Espera a resposta da API ou o erro do front
    const resposta = this.page.waitForResponse((r) => r.url().endsWith('/api/pedidos'));
    const erroDoFront = this.page.locator('.mensagem-erro').first().waitFor().then(() => null);
    // Evita erro de promise não tratada
    resposta.catch(() => {});
    erroDoFront.catch(() => {});
    await this.page.getByRole('button', { name: 'Confirmar pedido' }).click();
    this.ultimaResposta = await Promise.race([resposta, erroDoFront]);
  }

  numeroPedido(): Locator {
    return this.page.locator('.numero-pedido');
  }
}
