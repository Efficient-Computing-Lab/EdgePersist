# EdgePersist

[EdgePersist](https://antonismakris.github.io/edgestorageenabler/) is a package of components that enable edge storage for IoT and smart device edge networks.

It contains three main components:
* **Edge Storage Component**: the core component that provides the edge storage capabilities based on MinIO and K8s 
*  **Edge Localized Docker Registry**: the localized docker registry that uses the edge storage component as a back end for real-time and proactive docker image migration and replication
* **Edge Registry Sync Daemon**: a daemon process that syncs the localized registry to one or more remote ones based on a Kafka message bus

Each folder includes an individual readme file containing comprehensive installation and usage instructions for its corresponding component.


## Cite Us

If you use the above code for your research, please cite our papers:

- [A lightweight storage framework for edge computing infrastructures/EdgePersist](https://www.sciencedirect.com/science/article/pii/S2665963823000866)
       
      @article{psomakelis2023lightweight,
      title={A lightweight storage framework for edge computing infrastructures/EdgePersist},
      author={Psomakelis, Evangelos and Makris, Antonios and Tserpes, Konstantinos and   Pateraki, Maria},
      journal={Software Impacts},
      volume={17},
      pages={100549},
      year={2023},
      publisher={Elsevier}
      }  
- [Streamlining XR Application Deployment with a Localized Docker Registry at the Edge](https://link.springer.com/chapter/10.1007/978-3-031-46235-1_12)

      @inproceedings{makris2023streamlining,
      title={Streamlining XR Application Deployment with a Localized Docker Registry at the Edge},
      author={Makris, Antonios and Psomakelis, Evangelos and Korontanis, Ioannis and Theodoropoulos, Theodoros and Protopsaltis, Antonis and Pateraki, Maria and Ledwo{\'n}, Zbyszek and Diou, Christos and Anagnostopoulos, Dimosthenis and Tserpes, Konstantinos},
      booktitle={European Conference on Service-Oriented and Cloud Computing},
      pages={188--202},
      year={2023},
      organization={Springer}
      }
- [Towards a distributed storage framework for edge computing infrastructures](https://dl.acm.org/doi/abs/10.1145/3526059.3533617)

      @inproceedings{makris2022towards,
      title={Towards a distributed storage framework for edge computing infrastructures},
      author={Makris, Antonios and Psomakelis, Evangelos and Theodoropoulos, Theodoros and Tserpes, Konstantinos},
      booktitle={Proceedings of the 2nd Workshop on Flexible Resource and Application Management on the Edge},
      pages={9--14},
      year={2022}
      }