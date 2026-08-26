# Physical TRNG

This project aims to create a fully formally proven software library that uses physical sources as entropy sources for True Random Number Generator (TRNG). I will be composed of a core engine and an extendable static API to add physical sources such as Lava Lamp, Radioactive Decay... 

## Stack 

We use [Formosa KECCAK](https://formosa-crypto.org/projects/formosakeccak) as a formally proven cryptographical implementation of functions used inside our core engine. You can connect proprietary crpytographical implementations using the appropriate crate feature.  

The rest of the software will be made using [Rust Creusot](https://creusot.rs). 

## References 

- [NIST SP 800-90A Rev. 1](https://doi.org/10.6028/NIST.SP.800-90Ar1): Recommendation for Random Number Generation Using Deterministic Random Bit Generators.
- [NIST SP 800-90B](https://doi.org/10.6028/NIST.SP.800-90B): Recommendation for the Entropy Sources Used for Random Bit Generation. 
- [NIST SP 800-90C](https://doi.org/10.6028/NIST.SP.800-90C): Recommendation for Random Bit Generator (RBG) Constructions.
- [NIST SP 800-22 Rev. 1a](https://doi.org/10.6028/NIST.SP.800-22r1a): A Statistical Test Suite for Random and Pseudorandom Number Generators for Cryptographic Applications.
- [BSI AIS 31](https://www.bsi.bund.de/EN/Themen/Unternehmen-und-Organisationen/Standards-und-Zertifizierung/Zertifizierung-und-Anerkennung/Zertifizierung-von-Produkten/Zertifizierung-nach-CC/Anwendungshinweise-und-Interpretationen/anwendungshinweise-und-interpretationen_node.html): Multiple documents. 

_All the references are available free of charge following the links; I also regrouped them at https://kdrive.infomaniak.com/app/share/1926560/59e64735-4282-4d51-b705-4bf41fb9aaa6_.


