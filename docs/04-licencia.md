# 04 · Licencia y propiedad

> Orientación general, no asesoría legal. Antes de firmar con una empresa conviene
> revisarlo con un abogado de propiedad intelectual.

## Recomendación: licencia cerrada (propietaria) + repositorio privado

Si a futuro quieres **ofrecer la app a otras empresas** (venta, suscripción o licencia de
uso), lo más simple y seguro es:

1. **«Todos los derechos reservados»** (licencia propietaria) desde hoy. Ya está indicado
   en el `README.md`.
2. **Hacer privado el repositorio en GitHub.** Hoy `app-fenolog-a-` es **público**: aunque
   sin licencia nadie tiene permiso legal para usar el código, cualquiera puede verlo y
   copiar ideas.
3. Cuando aparezca un cliente: un **contrato de licencia de uso (EULA) o de suscripción
   (SaaS)** que defina qué puede hacer la empresa y quién es dueño de los datos.

Siempre se puede **abrir** el código más adelante; lo contrario (cerrar algo que ya se
publicó con licencia abierta) no se puede deshacer para las copias ya distribuidas.

## Alternativas

| Opción | Cómo funciona | Conviene si… |
|---|---|---|
| **Propietaria** (recomendada) | Nadie puede usar el código sin tu permiso. | Quieres vender o licenciar a empresas. |
| **Código visible con uso restringido** (BSL 1.1 o FSL) | Se ve el código, pero no se puede usar comercialmente; se vuelve abierto tras 2-4 años. | Quieres transparencia sin regalar el negocio. |
| **AGPL-3.0 + licencia comercial (doble licencia)** | Abierto, pero quien lo use en su servicio debe abrir su código o pagarte una licencia comercial. | Quieres comunidad y también ingresos. Más complejo de administrar. |
| **MIT / Apache-2.0** | Cualquiera puede usarlo, incluso para competir contigo. | No te interesa vender el software. |

## Otros puntos de propiedad

- **Datos de los usuarios:** son de cada usuario u organización. La cuenta maestra solo
  usa fotos y marcas **con consentimiento explícito y revocable** (ver modelo de datos).
  Los términos de uso deben decir que los **modelos de IA entrenados son tuyos**.
- **Dependencias:** usar librerías con licencias permisivas (MIT, BSD, Apache-2.0).
  Evitar AGPL/GPL dentro de la app (por eso no YOLO de Ultralytics sin licencia comercial).
- **Escala BBCH:** los códigos son un estándar de uso común; las **descripciones de los
  estadios se redactan nuevas** para no copiar textos de publicaciones.
- **Nombre y logo:** antes de publicar en tiendas, revisar que el nombre no esté
  registrado como marca (en Chile, en INAPI).
