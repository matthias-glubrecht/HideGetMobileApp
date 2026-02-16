import { override } from '@microsoft/decorators';
import {
  BaseApplicationCustomizer
} from '@microsoft/sp-application-base';

/** A Custom Action which can be run during execution of a Client Side Application */
export default class HideMobileUpsellLinkApplicationCustomizer
  extends BaseApplicationCustomizer<{}> {

  @override
  public onInit(): Promise<void> {
    this.addStyleToPage();
    return Promise.resolve();
  }

  private addStyleToPage(): void {
    const selector: string = 'div[class*="feedback_"]:has(> a[class*="MobileUpsellView_"])';
    const style: HTMLStyleElement = document.createElement('style');
    style.innerHTML = `${selector} { display: none !important; }`;
    document.head.appendChild(style);
  }
}
